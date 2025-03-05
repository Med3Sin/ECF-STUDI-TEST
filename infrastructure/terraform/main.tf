terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"  # Paris region
}

# Create a secret for RDS credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "yourmedia/rds/credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
    engine   = "mysql"
    host     = aws_db_instance.mysql.endpoint
    port     = 3306
    dbname   = aws_db_instance.mysql.db_name
  })
}

# Generate a random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet for RDS
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = {
    Name = "rds-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"  # Free tier eligible
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-11-amazon-corretto
              yum install -y tomcat
              yum install -y amazon-cloudwatch-agent
              yum install -y jq
              
              # Get database credentials from Secrets Manager
              SECRET_ARN="${aws_secretsmanager_secret.rds_credentials.arn}"
              CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region eu-west-3 | jq -r '.SecretString')
              
              # Extract credentials
              DB_HOST=$(echo $CREDENTIALS | jq -r '.host')
              DB_USER=$(echo $CREDENTIALS | jq -r '.username')
              DB_PASS=$(echo $CREDENTIALS | jq -r '.password')
              DB_NAME=$(echo $CREDENTIALS | jq -r '.dbname')
              
              # Create application.properties file
              mkdir -p /usr/share/tomcat/webapps/yourmedia/WEB-INF/classes
              cat > /usr/share/tomcat/webapps/yourmedia/WEB-INF/classes/application.properties << EOL
              spring.datasource.url=jdbc:mysql://\${DB_HOST}/\${DB_NAME}
              spring.datasource.username=\${DB_USER}
              spring.datasource.password=\${DB_PASS}
              EOL
              
              systemctl start tomcat
              systemctl enable tomcat
              EOF

  tags = {
    Name = "web-server"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier           = "yourmedia-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"  # Free tier eligible
  allocated_storage   = 20
  storage_type        = "gp2"
  db_name             = "yourmedia"
  username           = "admin"
  password           = random_password.db_password.result
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  # Free tier optimizations
  backup_retention_period = 0  # Disable backups to save storage
  backup_window          = "03:00-04:00"  # Off-peak hours
  maintenance_window     = "Mon:04:00-Mon:05:00"  # Off-peak hours
  multi_az              = false  # Disable Multi-AZ deployment
  publicly_accessible   = false  # Keep in private subnet
  storage_encrypted     = false  # Disable encryption to save CPU
  performance_insights_enabled = false  # Disable performance insights

  tags = {
    Name = "yourmedia-db"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "DB subnet group"
  }
}

# S3 Bucket for media storage
resource "aws_s3_bucket" "media_bucket" {
  bucket = "yourmedia-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "media-storage"
  }
}

# Random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "media_bucket" {
  bucket = aws_s3_bucket.media_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "media_bucket" {
  bucket = aws_s3_bucket.media_bucket.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "YourMedia-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.web_server.id],
            [".", "MemoryUtilization", ".", "."],
            [".", "DiskReadOps", ".", "."],
            [".", "DiskWriteOps", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "EC2 Performance Metrics"
        }
      },
      # RDS Metrics
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.mysql.id],
            [".", "FreeableMemory", ".", "."],
            [".", "FreeStorageSpace", ".", "."],
            [".", "DatabaseConnections", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "RDS Performance Metrics"
        }
      },
      # Application Metrics
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["SpringBoot", "http.server.requests", "uri", "/actuator/health"],
            [".", "jvm.memory.used", "area", "heap"],
            [".", "jvm.gc.pause", "action", "end of major GC"],
            [".", "jvm.threads.live", "type", "daemon"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "Spring Boot Application Metrics"
        }
      },
      # S3 Metrics
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/S3", "NumberOfObjects", "BucketName", aws_s3_bucket.media_bucket.id, "StorageType", "AllStorageTypes"],
            [".", "BucketSizeBytes", ".", ".", "StorageType", "StandardStorage"],
            [".", "FirstByteLatency", ".", ".", "FilterId", "EntireBucket"],
            [".", "Errors", ".", ".", "FilterId", "EntireBucket"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "S3 Storage Metrics"
        }
      },
      # Network Metrics
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.web_server.id],
            [".", "NetworkOut", ".", "."],
            [".", "NetworkPacketsIn", ".", "."],
            [".", "NetworkPacketsOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "Network Traffic Metrics"
        }
      },
      # Custom Business Metrics
      {
        type   = "metric"
        x      = 0
        y      = 30
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["YourMedia", "media.uploads.total", "type", "image"],
            [".", "media.uploads.total", "type", "video"],
            [".", "media.compression.success", "type", "image"],
            [".", "media.compression.success", "type", "video"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "eu-west-3"
          title   = "Business Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "ec2-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_alarm" {
  alarm_name          = "rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mysql.id
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "yourmedia-alerts"
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# Outputs
output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "media_bucket_name" {
  value = aws_s3_bucket.media_bucket.id
}

# IAM Role for EC2 to access Secrets Manager
resource "aws_iam_role" "ec2_secrets_access" {
  name = "ec2-secrets-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Secrets Manager access
resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-access"
  role = aws_iam_role.ec2_secrets_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.rds_credentials.arn]
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-secrets-profile"
  role = aws_iam_role.ec2_secrets_access.name
} 