#Configuring the NAT Gateways
resource "aws_nat_gateway" "ryan_cafe_nat_gateways" {
  for_each = var.nat_gateway_configs

  allocation_id = each.value.allocation_id
  subnet_id = each.value.subnet_id

  tags = {
    "Name" = "${each.key}-nat_gateway"
  }
}