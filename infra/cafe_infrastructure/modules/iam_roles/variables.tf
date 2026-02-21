variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# EC2 (DB ADMIN) SSM VARIABLES
variable "db_ec2_ssm_role_name" {
  description = "The role name for the dedicated db ec2"
  type = string
  default = "CafeEC2DataBaseSSMRole"
}


# ECS ROLES VARIABLES
variable "ecs_execution_role_name" {
  description = "Name of the shared ECS task execution role"
  type = string
  default = "CafeECSTaskExecutionRole"
}

variable "ecs_web_task_role_name" {
  description = "Name of the ECS task role for the web-frontend service"
  type = string
  default = "CafeECSWebTaskRole"
}

variable "ecs_orders_task_role_name" {
  description = "Name of the ECS task role for the order-service"
  type = string
  default = "CafeECSOrdersTaskRole"
}

variable "web_secret_arns" {
  description = "Secrets Manager ARNs that web-frontend is allowed to read"
  type = list(string)
}

variable "orders_secret_arns" {
  description = "Secrets Manager ARNs that order-service is allowed to read"
  type = list(string)
}

variable "order_events_queue_arn" {
  description = "ARN of the SQS queue where order-service publishes events (consumed by Lamda)"
  type = string
}

# LAMBDA VARIABLES
variable "lambda_email_role_name" {
  description = "Name of the Lambda role used for email sending (SQS->Lambda->SES)"
  type = string
  default = "CafeLambdaEmailSenderRole"
}

variable "db_ec2_ssm_profile_name" {
  description = "Name of the db EC2 Instance Profile"
  type = string
  default = "CafeDedicatedDBSSMProfile"
}