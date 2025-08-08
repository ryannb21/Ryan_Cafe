#Generating the random bucket suffix for uniqueness
resource "random_id" "cafe_bucket_suffix" {
  byte_length = 4
}

##Configuring the s3 bucket for terraform state file
resource "aws_s3_bucket" "cafe_app_tf_state" {
  bucket = "${var.tf_state_bucket_prefix}-${random_id.cafe_bucket_suffix.hex}"
  force_destroy = true
#   lifecycle {
#     prevent_destroy = true
#   } <- This is commented out to facilitate destruction, BUT is necessary in real environments
  tags = {
    "Name" = "Terraform State Bucket"
  }
}

#Enforcing bucket ownership control
resource "aws_s3_bucket_ownership_controls" "cafe_app_ownership" {
  bucket = aws_s3_bucket.cafe_app_tf_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#Configuring server-side encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "cafe_app_encryption" {
  bucket = aws_s3_bucket.cafe_app_tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Configuring bucket versioning
resource "aws_s3_bucket_versioning" "cafe_app_bucket_versioning" {
  bucket = aws_s3_bucket.cafe_app_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Configuring the DynamoDB table for terraform lock
resource "aws_dynamodb_table" "tf_lock" {
  name = "${var.dynamodb_table}-${random_id.cafe_bucket_suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "Name" = "Terraform State Lock Table"
  }
}