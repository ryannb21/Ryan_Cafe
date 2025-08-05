output "alb_arn" {
  description = "The ARN of the ALB"
  value = aws_lb.ryan_cafe_alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value = aws_lb.ryan_cafe_alb.dns_name
}

output "zone_id" {
  description = "The Route 53 zone ID of the ALB"
  value = aws_lb.ryan_cafe_alb.zone_id
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value = aws_lb_target_group.cafe_target_group.arn
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value = aws_lb_listener.cafe_http_listener.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value = aws_lb_listener.cafe_https_listener.arn
}