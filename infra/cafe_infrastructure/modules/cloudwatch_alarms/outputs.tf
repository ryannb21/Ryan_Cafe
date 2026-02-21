output "dashboard_name" {
  value = aws_cloudwatch_dashboard.cafe_ops.dashboard_name
}

output "alarm_arns" {
  value = {
    web_cpu_high     = aws_cloudwatch_metric_alarm.web_cpu_high.arn
    web_mem_high     = aws_cloudwatch_metric_alarm.web_mem_high.arn
    orders_cpu_high  = aws_cloudwatch_metric_alarm.orders_cpu_high.arn
    orders_mem_high  = aws_cloudwatch_metric_alarm.orders_mem_high.arn
    alb_target_5xx   = aws_cloudwatch_metric_alarm.alb_target_5xx.arn
    lambda_errors    = aws_cloudwatch_metric_alarm.lambda_errors.arn
    sqs_backlog      = aws_cloudwatch_metric_alarm.sqs_backlog.arn
    dlq_visible      = aws_cloudwatch_metric_alarm.sqs_dlq_visible.arn
  }
}
