output "combined_role_arn" {
  description = "ARN of the created combined role"
  value = aws_iam_role.cafe_combined_role.arn
}

output "combined_instance_profile_name" {
  description = "Name of the combined instance profile"
  value = aws_iam_instance_profile.cafe_combined_profile.name
}