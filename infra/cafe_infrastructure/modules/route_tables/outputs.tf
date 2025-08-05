output "public_route_table_id" {
  value = aws_route_table.cafe_public_rt.id
}

output "app_private_route_table_id" {
  value = { for k, _ in var.app_subnet_ids : k => aws_route_table.cafe_app_private_rt[k].id }
}

output "db_private_route_table_id" {
  value = { for k, _ in var.db_subnet_ids : k => aws_route_table.cafe_db_private_rt[k].id }
}