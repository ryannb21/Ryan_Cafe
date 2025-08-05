output "aws_s3_bucket" {
  value = aws_s3_bucket.cafe_app_tf_state.bucket
}

output "aws_dynamodb_table" {
  value = var.dynamodb_table
}