#Creating the SNS Topic
resource "aws_sns_topic" "cafe_ecs_sns_topic" {
  name = "cafe_ecs_sns_topic"
  
  tags = {
    "Name" = "cafe ASG SNS Topic"
  }
}

#Creating the SNS Topic Subscription
resource "aws_sns_topic_subscription" "cafe_ASG_SNS_email" {
  for_each = toset(var.sns_topic_subscriber_email)
  
  topic_arn = aws_sns_topic.cafe_ecs_sns_topic.arn
  protocol = "email"
  endpoint = each.value
}