#Configuring the Elastic IP Addresses
resource "aws_eip" "ryan_cafe_eips" {
  for_each = var.eip_configs

  domain = "vpc"
  tags = {
    "Name" = each.value.name
  }
}