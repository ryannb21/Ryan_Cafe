#Creating the DLQ
resource "aws_sqs_queue" "order_events_dlq" {
  name = var.dlq_name

  message_retention_seconds = var.dlq_message_retention_seconds
  sqs_managed_sse_enabled = var.sqs_managed_sse_enabled
  tags = var.common_tags
}

#Creating the Main Queue
resource "aws_sqs_queue" "order_events_queue" {
  name = var.queue_name

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  delay_seconds = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  max_message_size = var.max_message_size
  sqs_managed_sse_enabled = var.sqs_managed_sse_enabled

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_events_dlq.arn
    maxReceiveCount = var.max_receive_count
  })

  tags = var.common_tags
}