output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds.endpoint
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.rds.identifier
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.rds.status
}

output "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.rds.name
} 