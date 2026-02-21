locals {
  public_subnets = { for k, v in var.subnet_configs : k => v if v.tier == "public" }
  azs = distinct([for k, v in local.public_subnets : v.availability_zone])
  public_subnets_by_az = { for k, v in local.public_subnets : v.availability_zone => var.subnet_ids[k]... }
}

#Configuring the NAT Gateways
resource "aws_nat_gateway" "ryan_cafe_nat_gateways" {
  for_each = toset(local.azs)

  allocation_id = var.eip_allocation_ids[each.key]
  subnet_id = local.public_subnets_by_az[each.key][0]

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-nat-${each.key}"
    AZ = each.key
  })
}