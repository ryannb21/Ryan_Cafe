variable "aws_region" {
  description = "Region where SES is configured"
  type = string
}

variable "domain_name" {
  description = "Domain to verify in SES"
  type = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for the domain"
  type = string
}

variable "enable_mail_from" {
  description = "Whether to configure a custom MAIL FROM subdomain"
  type = bool
  default = true
}

variable "mail_from_subdomain" {
  description = "Subdomain for MAIL FROM"
  type = string
}