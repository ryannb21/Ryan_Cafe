variable "domain_name" {
  description = "The hosted zone domain name"
  type = string
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID for the domain"
  type = string
}