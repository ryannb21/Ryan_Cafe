#VPC Configuration
resource "aws_vpc" "ryan_cafe_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.common_tags, {
    Name = var.vpc_name
  })
}