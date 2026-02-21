variable "queue_name" {
  description = "Name of the main order events queue"
  type = string
}

variable "dlq_name" {
  description = "Name of the dead-letter queue"
  type = string
}

variable "max_receive_count" {
  description = "How many times a message can be receive before going to DLQ"
  type = number
  default = 5
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the main queue in seconds"
  type = number
  default = 60
}

variable "message_retention_seconds" {
  description = "Retention period for the DLQ in seconds"
  type = number
  default = 345600 #<- 4 days
}

variable "dlq_message_retention_seconds" {
  description = "Retention period for the DLQ in seconds"
  type = number
  default = 1209600 #<- 14 days
}

variable "delay_seconds" {
  description = "Deliverey delay for messages in seconds"
  type = number
  default = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time in seconds"
  type = number
  default = 10
}

variable "max_message_size" {
  description = "The maximum size i bytes (1-256KB)"
  type = number
  default = 262144
}

variable "sqs_managed_sse_enabled" {
  description = "Enable AWS-managed SSE for SQS"
  type = bool
  default = true
}

variable "common_tags" {
  description = "Common tags for resources"
  type = map(string)
  default ={}
}