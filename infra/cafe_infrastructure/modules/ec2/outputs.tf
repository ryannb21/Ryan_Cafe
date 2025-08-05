output "db_dedicated_ec2_instance_id" {
  value = aws_instance.cafe_db_dedicated_instance.id
}

output "db_dedicated_ec2_private_ip" {
  value = aws_instance.cafe_db_dedicated_instance.private_ip
}

output "db_dedicated_ec2_public_ip" {
  value = aws_instance.cafe_db_dedicated_instance.public_ip
  sensitive = true
}