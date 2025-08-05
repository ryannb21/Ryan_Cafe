#Subnets Configurations
resource "aws_subnet" "ryan_cafe_subnets" {
  for_each = var.subnet_configs

  vpc_id = var.vpc_id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.public

  tags = {
    "Name" = each.key
    Type = each.value.public ? "public" : "private"
  }
}