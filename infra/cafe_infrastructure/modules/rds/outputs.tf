output "rds_endpoint" {
  value = aws_db_instance.cafe_db.address
}

output "rds_arn" {
  value = aws_db_instance.cafe_db.arn
}
