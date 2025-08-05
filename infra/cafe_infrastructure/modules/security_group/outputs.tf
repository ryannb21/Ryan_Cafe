output "sg_ids" {
  description = "Map of security group names to IDs"
  value = {
    cafe_alb_sg = aws_security_group.cafe_alb_sg.id
    cafe_public_sg = aws_security_group.cafe_public_sg.id
    cafe_app_sg = aws_security_group.cafe_app_sg.id
    cafe_db_sg  = aws_security_group.cafe_db_sg.id
  }
}
