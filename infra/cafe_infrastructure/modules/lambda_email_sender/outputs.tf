output "lambda_arn" {
  description = "ARN of the email sender Lambda"
  value       = aws_lambda_function.email_sender.arn
}

output "lambda_name" {
  description = "Name of the email sender Lambda"
  value       = aws_lambda_function.email_sender.function_name
}
