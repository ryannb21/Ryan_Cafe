output "public_route_table_id" {
  description = "ID of the public route table"
  value = aws_route_table.cafe_public_rt.id
}

output "app_route_table_ids" {
  description = "Map of AZ to app route table IDs"
  value = { for k, v in aws_route_table.cafe_app_private_rt : k => v.id }
}

output "db_route_table_ids" {
  description = "Map of AZ to db route table IDs"
  value = { for k, v in aws_route_table.cafe_db_private_rt : k => v.id }
}