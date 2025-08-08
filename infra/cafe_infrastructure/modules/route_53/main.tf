#This section assumes YOU HAVE ALREADY PROCURED a domain name beforehand
data "aws_route53_zone" "ryan_cafe_main_zone" {
  name = var.main_zone_name
}

#Creating the cafe subdomain record in the main domain
resource "aws_route53_record" "ryan_cafe_subdomain" {
  zone_id = data.aws_route53_zone.ryan_cafe_main_zone.zone_id
  name    = var.sub_record_name
  type    = "A"

  alias {
    name = var.alb_dns_name
    zone_id = var.alb_zone_id
    evaluate_target_health = true
  }
}