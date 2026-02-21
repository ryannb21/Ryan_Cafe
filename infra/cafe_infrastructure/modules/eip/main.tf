locals {
  public_subnets = { for k, v in var.subnet_configs : k => v if v.tier == "public" }
  azs = distinct([for k, v in local.public_subnets : v.availability_zone])
}

#Configuring the Elastic IP Addresses
resource "aws_eip" "ryan_cafe_eips" {
  for_each = toset(local.azs)

  domain = "vpc"
  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-nat-eip-${each.key}"
    AZ = each.key
  })
}