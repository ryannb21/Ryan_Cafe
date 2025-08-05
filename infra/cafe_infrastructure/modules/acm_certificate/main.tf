resource "aws_acm_certificate" "domain_certificate" {
  domain_name = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
}

locals {
  first_dvo = tolist(aws_acm_certificate.domain_certificate.domain_validation_options)[0]
}

resource "aws_route53_record" "cert_attach" {
  count   = 1
  zone_id = var.route53_zone_id
  name    = local.first_dvo.resource_record_name
  type    = local.first_dvo.resource_record_type
  ttl     = 60
  records = [local.first_dvo.resource_record_value]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.domain_certificate.arn
  validation_record_fqdns = aws_route53_record.cert_attach[*].fqdn
}

