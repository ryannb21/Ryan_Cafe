variable "aws_region" {
  description = "The desired AWS region for the logs group"
  default = "us-east-1"
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}

variable "cafe_ecr_repo_url" {
  description = "The url of the ECR repo created"
  type        = string
}

variable "subnet_ids" {
  description = "The desired subnet ID for the ECS service"
  type = string
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type = string
}

variable "security_group_ids" {
  description = "The security group ID for the ECS service"
  type = string
}

variable "flask_secret_name" {
  description = "Secrets Manager name for the Flask secret_key"
  type = string
}

variable "email_secret_name" {
  description = "Secrets Manager name for the email credentials"
  type = string
}

variable "db_secret_name" {
  description = "Secrets Manager name for the database credentials"
  type = string
}