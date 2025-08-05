#Configuring the Internet Gateway
resource "aws_internet_gateway" "ryan_cafe_igw" {
  vpc_id = var.vpc_id

  tags = {
    "Name" = var.igw_name
  }
}