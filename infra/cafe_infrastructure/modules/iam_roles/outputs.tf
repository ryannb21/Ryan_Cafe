output "db_ec2_ssm_role_arn" {
  value = aws_iam_role.cafe_db_ec2_ssm_role.arn
}

output "db_ec2_ssm_profile_name" {
  value = aws_iam_instance_profile.db_ec2_ssm_profile.name
}

output "ecs_task_role_arn" {
  description = "ARN of the created ECS Task execution role"
  value = aws_iam_role.cafe_ecs_task_role.arn
}