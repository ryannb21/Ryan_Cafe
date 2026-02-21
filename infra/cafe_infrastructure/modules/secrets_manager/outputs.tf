output "db_secret_name" {
  value = aws_secretsmanager_secret.cafe_db_creds.name
}

output "app_secret_name" {
  value = aws_secretsmanager_secret.cafe_app_creds.name
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.cafe_db_creds.arn
}

output "app_secret_arn" {
  value = aws_secretsmanager_secret.cafe_app_creds.arn
}
