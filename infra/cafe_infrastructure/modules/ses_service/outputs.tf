output "domain_name" {
  description = "The verified SES domain"
  value = aws_ses_domain_identity.ses_domain_identity.domain
}

output "ses_identity_arn" {
  description = "SES identity ARN for the domain"
  value = "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identity/${aws_ses_domain_identity.ses_domain_identity.domain}"
}

output "mail_from_domain" {
  description = "MAIL FROM domain if enabled"
  value = var.enable_mail_from ? "${var.mail_from_subdomain}.${var.domain_name}" : null
}