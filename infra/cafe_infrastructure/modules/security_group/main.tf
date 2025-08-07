locals {
  default_egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  sg_name = "${var.sg_name_prefix}"
}


#ALB Security Group
resource "aws_security_group" "cafe_alb_sg" {
  name        = "ALB-sg-${local.sg_name}"
  description = "Allow HTTPS (443) from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  dynamic "egress" {
    for_each = [local.default_egress]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    "Name" = "ALB_SG-${var.sg_name_prefix}"
  }
}


#Public Security Group
resource "aws_security_group" "cafe_public_sg" {
  name        = "Public_SG-${local.sg_name}"
  description = "No ingress, public instances use SSM"
  vpc_id      = var.vpc_id

  dynamic "egress" {
    for_each = [local.default_egress]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    "Name" = "Public_SG-${var.sg_name_prefix}"
  }
}

#Fargate Security Group
resource "aws_security_group" "cafe_ecs_fargate_sg" {
  name        = "ECS_SG-${local.sg_name}"
  description = "Allows Fargate outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.cafe_alb_sg.id]
  }

  dynamic "egress" {
    for_each = [local.default_egress]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    "Name" = "ECS_SG-${var.sg_name_prefix}"
  }
}


#Database Security Group
resource "aws_security_group" "cafe_db_sg" {
  name        = "Database_SG-${local.sg_name}"
  description = "Allow MySQL (3306) from App"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.cafe_ecs_fargate_sg.id,
      aws_security_group.cafe_public_sg.id,
   ]
  }

  dynamic "egress" {
    for_each = [local.default_egress]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    "Name" = "Database_SG-${var.sg_name_prefix}"
  }
}