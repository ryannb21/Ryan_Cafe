locals {
  # Group subnets by tier
  public_subnets = { for k, v in var.subnet_configs : k => v if v.tier == "public" }
  app_subnets    = { for k, v in var.subnet_configs : k => v if v.tier == "app" }
  db_subnets     = { for k, v in var.subnet_configs : k => v if v.tier == "db" }
  
  # Get unique AZs for app and db subnets
  app_azs = distinct([for k, v in local.app_subnets : v.availability_zone])
  db_azs  = distinct([for k, v in local.db_subnets : v.availability_zone])
}

#Creating the Public Route Table
resource "aws_route_table" "cafe_public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags =  merge(var.common_tags,{
    Name = "${var.vpc_name}-public-RT"
    Type = "Public"
    Tier = "Public"
    })
}


#Associating Public RT to each Public Subnet
resource "aws_route_table_association" "cafe_public_rt_assoc" {
  for_each = local.public_subnets

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.cafe_public_rt.id
}


#Creating the App Route Table
resource "aws_route_table" "cafe_app_private_rt" {
  for_each = toset(local.app_azs)
  
  vpc_id = var.vpc_id
  
  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-app-rt-${each.key}"
    Type = "private"
    Tier = "app"
    AZ   = each.key
  })
}

#Adding NAT Gateway routes to app route tables
resource "aws_route" "cafe_app_nat_route" {
  for_each = var.nat_gateway_ids
  
  route_table_id         = aws_route_table.cafe_app_private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value
}


#Associating app-private RT to each App Subnet
resource "aws_route_table_association" "cafe_app_private_rt_assoc" {
  for_each = local.app_subnets

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.cafe_app_private_rt[each.value.availability_zone].id
}


#Creating the DB Route Table
resource "aws_route_table" "cafe_db_private_rt" {
  for_each = toset(local.db_azs)

  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-db-RT-${each.key}"
    Type = "Private"
    Tier = "DB"
    AZ   = each.key
  })
}

#Associating DB-private RT to each DB Subnet
resource "aws_route_table_association" "cafe_db_private_rt_assoc" {
  for_each = local.db_subnets

  subnet_id = each.value.subnet_id
  route_table_id = aws_route_table.cafe_db_private_rt[each.value.availability_zone].id
}