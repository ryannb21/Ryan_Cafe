variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}

variable "order_events_queue_arn" {
  description = "SQS queue ARN to trigger this Lambda"
  type        = string
}

variable "ses_region" {
  description = "Region where SES is configured"
  type        = string
  default     = "us-east-1"
}

variable "from_email" {
  description = "Verified FROM address under the SES-verified domain (e.g. orders@cafe.ryanb-lab.com)"
  type        = string
}

variable "reply_to" {
  description = "Optional reply-to address"
  type        = string
}

variable "app_name" {
  description = "App name shown in email subject/body"
  type        = string
  default     = "Ryan's Cafe"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "app.lambda_handler"
}

variable "timeout_seconds" {
  description = "Lambda timeout"
  type        = number
  default     = 10
}

variable "memory_mb" {
  description = "Lambda memory"
  type        = number
  default     = 128
}

variable "batch_size" {
  description = "SQS batch size"
  type        = number
  default     = 10
}

variable "max_batching_window_seconds" {
  description = "Max batching window for SQS trigger"
  type        = number
  default     = 5
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
