#Configuring CloudWatch to Monitor Instance Metrics to Trigger ASG
#Configuring the High_CPU_Alarm
resource "aws_cloudwatch_metric_alarm" "cafe_ecs_cloudwatch_cpu_alarm_high" {
  alarm_name = "Cafe-ECS-High-CPU-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_cpu_threshold
  alarm_description = "This alarm triggers at ${var.cw_high_cpu_threshold} CPU Util for ${var.cw_high_eval_periods} mins"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_actions = [var.cafe_ecs_sns_topic]
  ok_actions = [var.cafe_ecs_sns_topic]
}

#Configuring the Low_CPU_Alarm
resource "aws_cloudwatch_metric_alarm" "cafe_ecs_cloudwatch_cpu_alarm_low" {
  alarm_name = "Cafe-ECS-Low-CPU-Alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = var.cw_low_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = var.cw_low_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_low_cpu_threshold
  alarm_description = "This alarm triggers at ${var.cw_low_cpu_threshold} CPU Util for ${var.cw_low_eval_periods} mins"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_actions = [var.cafe_ecs_sns_topic]
  ok_actions = [var.cafe_ecs_sns_topic]
}