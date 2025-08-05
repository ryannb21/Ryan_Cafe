output "high_cpu_alarm_id" {
  value = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_high.id
}

output "low_cpu_alarm_id" {
  value = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_low.id
}

output "combined_alarm_arns" {
  value = {
    high_cpu_alarm_arn = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_high.arn
    low_cpu_alarm_arn  = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_low.arn
  }
}

output "combined_alarm_names" {
  value = {
    high_cpu_alarm_name = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_high.alarm_name
    low_cpu_alarm_name  = aws_cloudwatch_metric_alarm.cafe_asg_cloudwatch_cpu_alarm_low.alarm_name
  }
}