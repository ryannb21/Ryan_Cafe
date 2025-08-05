#Configuring CloudWatch to Monitor Instance Metrics to Trigger ASG
#Configuring the High_CPU_Alarm
resource "aws_cloudwatch_metric_alarm" "cafe_asg_cloudwatch_cpu_alarm_high" {
  alarm_name = "HighCPUAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_cpu_threshold
  alarm_description = "This alarm triggers at ${var.cw_high_cpu_threshold} CPU Util for ${var.cw_high_eval_periods} mins"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = [
      var.asg_scale_up_policy,
      var.asg_sns_topic
  ]
  ok_actions = [
      var.asg_sns_topic
  ]
}

#Configuring the Low_CPU_Alarm
resource "aws_cloudwatch_metric_alarm" "cafe_asg_cloudwatch_cpu_alarm_low" {
  alarm_name = "LowCPUAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = var.cw_low_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cw_low_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_low_cpu_threshold
  alarm_description = "This alarm triggers at ${var.cw_low_cpu_threshold} CPU Util for ${var.cw_low_eval_periods} mins"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = [
      var.asg_scale_down_policy,
      var.asg_sns_topic
  ]
  ok_actions = [
      var.asg_sns_topic
  ]
}