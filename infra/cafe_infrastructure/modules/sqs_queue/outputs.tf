output "order_events_queue_arn" {
  description = "ARN of the main order events queue"
  value = aws_sqs_queue.order_events_queue.arn
}

output "order_events_queue_url" {
  description = "URL of the main order events queue"
  value = aws_sqs_queue.order_events_queue.id
}

output "order_events_dlq_arn" {
  description = "ARN of the DLQ"
  value = aws_sqs_queue.order_events_dlq.arn
}

output "order_events_dlq_url" {
  description = "URL of the DLQ"
  value = aws_sqs_queue.order_events_dlq.id
}

output "order_events_queue_name" {
  description = "The name of the order events queue"
  value = aws_sqs_queue.order_events_queue.name
}

output "order_events_dlq_name" {
  description = "The name for the order events dlq"
  value = aws_sqs_queue.order_events_dlq.name
}