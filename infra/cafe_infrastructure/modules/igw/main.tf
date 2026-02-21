#Configuring the Internet Gateway
resource "aws_internet_gateway" "ryan_cafe_igw" {
  vpc_id = var.vpc_id

  tags =  merge(var.common_tags,{
    Name = "${var.vpc_name}-igw"
  })
}