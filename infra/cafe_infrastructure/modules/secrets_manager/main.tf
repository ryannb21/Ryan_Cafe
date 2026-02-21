#DATABASE CREDENTIALS
resource "aws_secretsmanager_secret" "cafe_db_creds" {
  name = "${var.secret_prefix}/db_creds"
  description = "Database credentials for ${var.db_name}"
  recovery_window_in_days = 7
}


resource "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = aws_secretsmanager_secret.cafe_db_creds.id

  secret_string = jsonencode({
    host = var.db_host
    user = var.db_username
    password = var.db_password
    database = var.db_name
  })
}


#APP CREDENTIALS
resource "aws_secretsmanager_secret" "cafe_app_creds" {
  name = "${var.secret_prefix}/flask_secret"
  description = "Flask secret key" 
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "app_creds_version" {
  secret_id = aws_secretsmanager_secret.cafe_app_creds.id

  secret_string = jsonencode({
    secret_key = var.app_key
  })
}