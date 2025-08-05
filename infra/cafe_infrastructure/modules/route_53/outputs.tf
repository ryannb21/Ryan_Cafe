output "main_zone_id" {
  description = "The Route 53 hosted zone ID for the main domain"
  value = data.aws_route53_zone.ryan_cafe_main_zone.zone_id
}

output "subdomain_fqdn" {
  description = "The Fully Qualified Domain Name of the created subdomain"
  value = aws_route53_record.ryan_cafe_subdomain.name
}

output "subdomain_zone_id" {
  description = "The Route 53 hosted zone ID for the main domain"
  value = aws_route53_record.ryan_cafe_subdomain.zone_id
}