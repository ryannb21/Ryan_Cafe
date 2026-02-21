data "aws_caller_identity" "current" {}

#Configuring the SES Domain Identity
resource "aws_ses_domain_identity" "ses_domain_identity" {
  domain = var.domain_name
}

#Setting Route53 TXT record for domain verification
resource "aws_route53_record" "ses_verification" {
  zone_id = var.route53_zone_id
  name = "_amazonses.${var.domain_name}"
  type = "TXT"
  ttl = 300
  records = [ aws_ses_domain_identity.ses_domain_identity.verification_token ]
}

#Setting a pause for verification to complete
resource "aws_ses_domain_identity_verification" "ses_domain_identity_verification" {
  domain = aws_ses_domain_identity.ses_domain_identity.domain
  depends_on = [ aws_route53_record.ses_verification ]
}

#Configuring DKIM
resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain_identity.domain
}

#Creating 3 DKIM CNAME records
resource "aws_route53_record" "dkim" {
  for_each = {
    dkim1 = aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[0]
    dkim2 = aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[1]
    dkim3 = aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[2]
  }

  zone_id = var.route53_zone_id
  name = "${each.value}._domainkey.${var.domain_name}"
  type = "CNAME"
  ttl = 300
  records = ["${each.value}.dkim.amazonses.com"]
}

#Configuring custom MAIL FROM subdomain
resource "aws_ses_domain_mail_from" "ses_domain_mail_from" {
  count = var.enable_mail_from ? 1 : 0

  domain = aws_ses_domain_identity.ses_domain_identity.domain
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain_name}"
  behavior_on_mx_failure = "UseDefaultValue"
}

#Configuring MX record for MAIL FROM domain
resource "aws_route53_record" "mail_from_mx" {
  count = var.enable_mail_from ? 1 : 0

  zone_id = var.route53_zone_id
  name = "${var.mail_from_subdomain}.${var.domain_name}"
  type = "MX"
  ttl = 300
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

#Configuring SPF TXT record for MAIL FROM domain
resource "aws_route53_record" "mail_from_spf" {
  count = var.enable_mail_from ? 1 : 0

  zone_id = var.route53_zone_id
  name = "${var.mail_from_subdomain}.${var.domain_name}"
  type = "TXT"
  ttl = 300
  records = ["v=spf1 include:amazonses.com -all"]
}