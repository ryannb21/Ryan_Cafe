output "db_admin_instance_id" {
  value = aws_instance.cafe_db_dedicated_instance.id
}

output "db_admin_private_ip" {
  value = aws_instance.cafe_db_dedicated_instance.private_ip
}