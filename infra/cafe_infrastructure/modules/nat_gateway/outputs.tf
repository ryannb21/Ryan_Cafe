output "nat_gateway_ids" {
  value = {for k, nat in aws_nat_gateway.ryan_cafe_nat_gateways : k => nat.id}
}

output "nat_gateway_ips" {
  value = {for k, nat in aws_nat_gateway.ryan_cafe_nat_gateways : k => nat.public_ip}
  sensitive = true
}