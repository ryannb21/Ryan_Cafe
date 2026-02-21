output "db_ec2_ssm_role_arn" {
  value = aws_iam_role.cafe_db_ec2_ssm_role.arn
}

output "db_ec2_ssm_profile_name" {
  value = aws_iam_instance_profile.db_ec2_ssm_profile.name
}

output "ecs_execution_role_arn" {
  description = "ARN of the shared ECS task execution role"
  value = aws_iam_role.cafe_ecs_execution_role.arn 
}

output "ecs_web_task_role_arn" {
  description = "ARN of the ECS task role for web-frontend"
  value = aws_iam_role.cafe_ecs_web_task_role.arn
}

output "ecs_orders_tasks_role_arn" {
  description = "ARN of the ECS task role for order-service"
  value = aws_iam_role.cafe_ecs_orders_task_role.arn 
}

output "lambda_email_role_arn" {
  description = "ARN of the lambda email sender role"
  value = aws_iam_role.cafe_lambda_email_role.arn
}