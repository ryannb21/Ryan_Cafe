output "cafe_alb_logs_bucket" {
  value = aws_s3_bucket.cafe_alb_logs_bucket.bucket
}

output "cafe_alb_logs_bucket_arn" {
  value = aws_s3_bucket.cafe_alb_logs_bucket.arn
}