variable "aws_region" {
  description = "Desired AWS region"
  type = string
}

variable "vpc_id" {
  description = "VPC id for service discovery namespace"
  type = string
}

variable "family" {
  description = "Base name used for ECS family/service names"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type = string
}

variable "ecs_log_group_name" {
  description = "CloudWatch log group name"
  type = string
}

variable "service_discovery_namespace_name" {
  description = "Private DNS namespace name"
  type = string
}

#Roles variables
variable "ecs_execution_role_arn" {
  description = "shared ECS execution role ARN"
  type = string
}

variable "ecs_web_task_role_arn" {
  description = "ECS task role ARN for web-frontend"
  type = string
}

variable "ecs_orders_task_role_arn" {
  description = "ECS task role ARN for order-servic"
  type = string
}


#Image variables
variable "web_image" {
  description = "Container image for web-frontend"
  type = string
}

variable "orders_image" {
  description = "Container image for the order-service"
  type = string
}

#Network variables
variable "app_subnet_ids" {
  description = "Private app subnet IDs (across AZs)"
  type        = list(string)
}

variable "web_security_group_ids" {
  description = "Security group IDs for web-frontend tasks"
  type        = list(string)
}

variable "orders_security_group_ids" {
  description = "Security group IDs for order-service tasks"
  type        = list(string)
}

#ALB -> WEB
variable "web_target_group_arn" {
  description = "Target group ARN for the web service"
  type        = string
}

#Secret names
variable "flask_secret_name" {
  description = "Secrets Manager name for the Flask secret_key"
  type        = string
}

variable "db_secret_name" {
  description = "Secrets Manager name for the database credentials"
  type        = string
}

#SQS Variables
variable "order_events_queue_url" {
  description = "SQS queue URL where order-service publishes events"
  type        = string
}

#Redis Variables
variable "redis_endpoint" {
  description = "Redis cluster endpoint"
  type        = string
}

variable "redis_port" {
  description = "Redis cluster port"
  type        = number
  default     = 6379
}

#Desired counts variables
variable "web_desired_count" {
  type    = number
  default = 2 #2
}

variable "orders_desired_count" {
  type    = number
  default = 1 #1
}

# Task sizing
variable "web_cpu" {
  type    = number
  default = 512
}

variable "web_memory" {
  type    = number
  default = 1024
}

variable "orders_cpu" {
  type    = number
  default = 256
}

variable "orders_memory" {
  type    = number
  default = 512
}

#Autosclaing variables
variable "web_min_capacity" {
  type    = number
  default = 1
}

variable "web_max_capacity" {
  type    = number
  default = 10
}

variable "orders_min_capacity" {
  type    = number
  default = 1
}

variable "orders_max_capacity" {
  type    = number
  default = 5
}

variable "web_cpu_target" {
  type    = number
  default = 50.0
}

variable "orders_cpu_target" {
  type    = number
  default = 50.0
}