output "eip_allocation_ids" {
  value = {for k, eip in aws_eip.ryan_cafe_eips : k => eip.id}
}

output "public_ips" {
  value = {for k, eip in aws_eip.ryan_cafe_eips: k => eip.public_ip}
  sensitive = true
}