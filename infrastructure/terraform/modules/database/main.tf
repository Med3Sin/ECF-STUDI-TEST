resource "aws_db_instance" "rds" {
  identifier           = "ecf-${var.environment}-db"
  engine              = "postgres"
  engine_version      = "14.7"
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = var.storage_type
  db_name             = var.db_name
  username           = var.db_username
  password           = var.db_password

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az              = var.environment == "production"

  backup_retention_period = 7
  backup_window          = "03:00-04:00"

  tags = {
    Name        = "ecf-${var.environment}-db"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "ecf-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "ecf-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "ecf-${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.rds.endpoint
    port     = 5432
    dbname   = var.db_name
  })
} 