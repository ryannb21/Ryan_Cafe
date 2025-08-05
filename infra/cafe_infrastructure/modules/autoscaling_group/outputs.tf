output "launch_template_id" {
  value = aws_launch_template.cafe_ASG_LaunchTemplate.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.cafe_ASG.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.cafe_ASG.arn
}

output "scale_up_policy_arn" {
  description = "ARN of the scale-up policy"
  value = aws_autoscaling_policy.cafe_asg_scale_up.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale-down policy"
  value = aws_autoscaling_policy.cafe_asg_scale_down.arn
}