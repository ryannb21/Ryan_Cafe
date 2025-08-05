#Generating the random bucket suffix for uniqueness
resource "random_id" "cafe_alb_logs_bucket_suffix" {
  byte_length = 4
}

#Configuring the s3 bucket for alb logs
resource "aws_s3_bucket" "cafe_alb_logs_bucket" {
  bucket = "${var.alb_logs_bucket_name}-${random_id.cafe_alb_logs_bucket_suffix.hex}"
  force_destroy = true
#   lifecycle {
#     prevent_destroy = true
#   }<- Commented out to facilitate destruction, BUT is necessary in real environments
tags = {
    Name = "cafe_alb_logs_bucket"
  } 
}

#Data sourcing the elb_service_account number and configuring the s3 bucket policy
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "cafe_alb_logs_bucket_policy" {
  bucket = aws_s3_bucket.cafe_alb_logs_bucket.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
            {
                  Effect = "Allow"
                  Principal = {
                        AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
                  }
                  Action = "s3:PutObject"
                  Resource = "${aws_s3_bucket.cafe_alb_logs_bucket.arn}/*"
            },
            {
                  Effect = "Allow"
                  Principal = {
                        Service = "delivery.logs.amazonaws.com"
                  }
                  Action = "s3:PutObject"
                  Resource = "${aws_s3_bucket.cafe_alb_logs_bucket.arn}/*"
                  Condition = {
                        StringEquals = {
                              "s3:x-amz-acl" = "bucket-owner-full-control"
                        }
                  }
            }
      ]
  })
}

#Blocking public access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "cafe_alb_logs_bucket_public_access_block" {
  bucket = aws_s3_bucket.cafe_alb_logs_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#Configuring server-side encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.cafe_alb_logs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Configuring versioning for the bucket
resource "aws_s3_bucket_versioning" "cafe_alb_logs_bucket_versioning" {
  bucket = aws_s3_bucket.cafe_alb_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}