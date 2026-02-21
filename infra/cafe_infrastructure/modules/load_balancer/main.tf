#Configuring the Application Load Balancer
resource "aws_lb" "ryan_cafe_alb" {
  name = "${var.vpc_name}-alb"
  internal = false 
  load_balancer_type = "application"
  security_groups = [var.alb_security_group_id]
  subnets = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection 
  drop_invalid_header_fields = true
  # access_logs {
  #   bucket = var.alb_access_logs_bucket_name
  #   enabled = true
  # }
  tags = merge(var.common_tags, {
    Name = "${var.vpc_name}-alb"
  })
}


#Creating the Cafe Target Group
resource "aws_lb_target_group" "cafe_target_group" {
  name = "${var.vpc_name}-TG"
  port = var.target_group_port
  protocol = "HTTP"
  target_type = var.target_type
  vpc_id = var.vpc_id
  
  health_check {
    protocol = "HTTP"
    path = var.health_check_path
    interval = var.health_check_interval
    timeout = 10
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200-299"
  }

  tags = merge(var.common_tags, {
    "Name" = "${var.vpc_name}-TG"
  })
}


#Creating the Cafe listener for HTTPS
resource "aws_lb_listener" "cafe_https_listener" {
  load_balancer_arn = aws_lb.ryan_cafe_alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cafe_target_group.arn
  }
}

#Creating the Cafe listener for HTTP
resource "aws_lb_listener" "cafe_http_listener" {
  load_balancer_arn = aws_lb.ryan_cafe_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
      host = "#{host}"
      path = "/#{path}"
      query = "#{query}"
    }
  }
}