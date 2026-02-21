#Creating the SNS Topic
resource "aws_sns_topic" "cafe_alerts_topic" {
  name = var.sns_topic_name
  
  tags = merge(var.common_tags, {
    "Name" = var.sns_topic_name
  })
}

#Creating the SNS Topic Subscription
resource "aws_sns_topic_subscription" "cafe_alerts_email_subs" {
  for_each = toset(var.sns_topic_subscriber_email)
  
  topic_arn = aws_sns_topic.cafe_alerts_topic.arn
  protocol = "email"
  endpoint = each.value
}