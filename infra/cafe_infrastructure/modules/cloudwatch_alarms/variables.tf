#Shared Variables
variable "aws_region" {
  description = "AWS region for dashboard widgets"
  type        = string
}


variable "sns_topic_arn" {
  description = "SNS topic arn for alarm notifications"
  type = string
  default = ""
}

variable "dashboard_name" {
  description = "The CloudWatch dashboard name"
  type = string
}

#ECS Variables
variable "ecs_cluster_name" {
  description = "The ECS Cluster name"
  type = string
}

variable "web_service_name" {
  description = "The ECS web service name"
  type        = string
}

variable "orders_service_name" {
  description = "The ECS orders service name"
  type        = string
}

variable "cw_high_eval_periods" {
  type    = number
  default = 2
}

variable "cw_high_cpu_eval_duration" {
  type    = number
  default = 60
}

variable "cw_high_cpu_threshold" {
  type    = number
  default = 75
}

variable "cw_high_mem_threshold" {
  description = "Memory utilization threshold"
  type        = number
  default     = 80
}

#ALB Variables
variable "alb_arn_suffix" {
  description = "ALB ARN suffix (not full ARN). Example: app/my-alb/123abc"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix (not full ARN). Example: targetgroup/my-tg/123abc"
  type        = string
}

variable "alb_target_5xx_threshold" {
  type    = number
  default = 5
}

#Lambda Variables
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_errors_threshold" {
  type    = number
  default = 1
}

#SQS Variables
variable "order_events_queue_name" {
  description = "Main SQS queue name"
  type        = string
}

variable "order_events_dlq_name" {
  description = "DLQ queue name"
  type        = string
}

variable "sqs_backlog_threshold" {
  type    = number
  default = 10
}

variable "dlq_visible_threshold" {
  type    = number
  default = 1
}