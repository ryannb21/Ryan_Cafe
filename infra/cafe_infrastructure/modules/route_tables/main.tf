#Creating the Public Route Table
resource "aws_route_table" "cafe_public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = { Name = var.public_rt_name }
}


#Associating Public RT to each Public Subnet
resource "aws_route_table_association" "cafe_public_rt_assoc" {
  for_each = var.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.cafe_public_rt.id
}


#Creating the App Route Table
resource "aws_route_table" "cafe_app_private_rt" {
  vpc_id = var.vpc_id
  for_each = var.app_subnet_ids
  # Using one NAT for each AZ as we have 2 NATs
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[each.key]
  }
  tags = { Name = "${each.key}-RT"}
}


#Associating app-private RT to each App Subnet
resource "aws_route_table_association" "cafe_app_private_rt_assoc" {
  for_each = var.app_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.cafe_app_private_rt[each.key].id
}


#Creating the DB Route Table
resource "aws_route_table" "cafe_db_private_rt" {
  for_each = var.db_subnet_ids
  vpc_id = var.vpc_id
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_ids[replace(each.key, "DB", "App")]
  }
  tags = {
    "Name" = "${each.key}-RT"
  }
}

#Associating DB-private RT to each DB Subnet
resource "aws_route_table_association" "cafe_db_private_rt_assoc" {
  for_each = var.db_subnet_ids
  subnet_id = each.value
  route_table_id = aws_route_table.cafe_db_private_rt[each.key].id
}