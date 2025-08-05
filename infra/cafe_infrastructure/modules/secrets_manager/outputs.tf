output "db_secret_arn" {
  value = aws_secretsmanager_secret.cafe_db_creds.arn
}

output "email_secret_arn" {
  value = aws_secretsmanager_secret.cafe_email_creds.arn
}

output "app_secret_arn" {
  value = aws_secretsmanager_secret.cafe_app_creds.arn
}