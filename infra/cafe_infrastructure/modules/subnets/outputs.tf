output "subnet_ids" {
  value = { for subnet_key, subnet in aws_subnet.ryan_cafe_subnets : subnet_key => subnet.id }
}

output "subnet_details" {
  description = "Detailed subnet information for route table associations"
  value = {
    for k, subnet in aws_subnet.ryan_cafe_subnets : k => {
      subnet_id         = subnet.id
      availability_zone = subnet.availability_zone
      public            = subnet.map_public_ip_on_launch
      tier              = var.subnet_configs[k].tier
    }
  }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [ for k, v in aws_subnet.ryan_cafe_subnets : v.id if v.map_public_ip_on_launch == true]
}

output "app_subnet_ids" {
  description = "List of private subnet IDs"
  value = [ for k, s in aws_subnet.ryan_cafe_subnets : s.id if var.subnet_configs[k].tier == "app"]
}

output "db_subnet_ids" {
  description = "List of private subnet IDs"
  value = [ for k, s in aws_subnet.ryan_cafe_subnets : s.id if var.subnet_configs[k].tier == "db"]
}