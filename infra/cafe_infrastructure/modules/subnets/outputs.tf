output "subnet_ids" {
  value = { for subnet_key, subnet in aws_subnet.ryan_cafe_subnets : subnet_key => subnet.id }
}