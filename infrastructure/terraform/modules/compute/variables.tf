variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for EC2 instance"
  type        = string
}

variable "secrets_arns" {
  description = "ARNs of secrets to access"
  type        = list(string)
} 