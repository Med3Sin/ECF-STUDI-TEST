variable "environment" {
  description = "Environment name (e.g., development, production)"
  type        = string
  default     = "development"
}

variable "ec2_role_arn" {
  description = "ARN of the EC2 instance role that needs access to the S3 bucket"
  type        = string
} 