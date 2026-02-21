variable "sns_topic_name" {
  description = "SNS topic name for alerts"
  type = string
  default = "cafe-alerts-topic"
}

variable "sns_topic_subscriber_email" {
  description = "The desired email to subscribe to the SNS Topic"
  type = list(string)
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}