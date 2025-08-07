output "aws_s3_tfstate_bucket_name" {
  value = aws_s3_bucket.cafe_app_tf_state.bucket
}

output "aws_dynamodb_table" {
  value = aws_dynamodb_table.tf_lock.name
}