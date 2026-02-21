output "sns_topic_name" {
  description = "The name of the SNS topic"
  value = aws_sns_topic.cafe_alerts_topic.name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value = aws_sns_topic.cafe_alerts_topic.arn
}