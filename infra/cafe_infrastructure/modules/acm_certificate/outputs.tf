output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value = aws_acm_certificate.domain_certificate.arn
}

output "certificate_id" {
  description = "The ID of the ACM certificate"
  value = aws_acm_certificate.domain_certificate.id
}

output "aws_acm_certificate_validation" {
  description = "Completion status of the ACM cert validation"
  value = aws_acm_certificate_validation.cert_validation.id
}