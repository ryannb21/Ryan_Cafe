#Generating the random bucket suffix for uniqueness
resource "random_id" "cafe_logs_bucket_suffix" {
  byte_length = 4
}

#Configuring the s3 bucket for alb logs
resource "aws_s3_bucket" "cafe_alb_logs_bucket" {
  bucket = "${var.alb_logs_bucket_name}-${random_id.cafe_logs_bucket_suffix.hex}"
  force_destroy = true
#   lifecycle {
#     prevent_destroy = true
#   }<- This is commented out to facilitate destruction, BUT is necessary in real environments
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
resource "aws_s3_bucket_server_side_encryption_configuration" "cafe_alb_logs_bucket_encrypt" {
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


###CONFIGURING THE VPC FLOW LOGS###
#Configuring S3 Bucket for VPC Flow Logs
resource "aws_s3_bucket" "cafe_vpc_flow_logs_bucket" {
  bucket = "${var.vpc_flow_logs_bucket_name}-${random_id.cafe_logs_bucket_suffix.hex}"
  force_destroy = true
  # lifecycle {
  #   prevent_destroy = true
  # }<- This is commented out to facilitate destruction, BUT is necessary in real environments
  tags = {
    Name = "cafe_vpc_flow_logs_bucket"
  }
}

resource "aws_s3_bucket_policy" "cafe_vpc_flow_logs_bucket_policy" {
  bucket = aws_s3_bucket.cafe_vpc_flow_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowVPCFlOWLogsGetACL"
        Effect = "Allow"
        Principal = {Service = "vpc-flow-logs.amazonaws.com"}
        Action = "s3:GetBucketAcl"
        Resource = "${aws_s3_bucket.cafe_vpc_flow_logs_bucket.arn}"
      },
      {
        Sid = "AllowVPCFlOWLogsWrite"
        Effect = "Allow"
        Principal = {Service = "vpc-flow-logs.amazonaws.com"}
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          ]
        Resource = "${aws_s3_bucket.cafe_vpc_flow_logs_bucket.arn}/*"
      }
    ]
  })
}

#Creating the role to be assumed by the flow logs
data "aws_iam_policy_document" "cafe_vpc_flow_logs_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cafe_vpc_flow_logs_role" {
  name = "cafe_vpc_flow_logs_role"
  assume_role_policy = data.aws_iam_policy_document.cafe_vpc_flow_logs_assume_role_policy.json
}

#Permitting the role to put objects into the bucket
data "aws_iam_policy_document" "cafe_vpc_flow_logs_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.cafe_vpc_flow_logs_bucket.arn}/*"]
  }
}

resource "aws_iam_role_policy" "cafe_vpc_flow_logs_policy" {
  name = "cafe_vpc_flow_logs_policy"
  policy = data.aws_iam_policy_document.cafe_vpc_flow_logs_role_policy.json
  role = aws_iam_role.cafe_vpc_flow_logs_role.id
}

#Configuring the flow logs
resource "aws_flow_log" "cafe_vpc_flow_logs" {
  vpc_id = var.vpc_id
  log_destination_type = "s3"
  log_destination = aws_s3_bucket.cafe_vpc_flow_logs_bucket.arn
  traffic_type = "ALL"
  max_aggregation_interval = 600
}

#Blocking public access to the vpc flow logs bucket
resource "aws_s3_bucket_public_access_block" "cafe_flow_logs_bucket_public_access_block" {
  bucket = aws_s3_bucket.cafe_vpc_flow_logs_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#Configuring server-side encryption for the flow logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "cafe_flow_logs_bucket_encrypt" {
  bucket = aws_s3_bucket.cafe_vpc_flow_logs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Configuring versioning for the flow logs bucket
resource "aws_s3_bucket_versioning" "cafe_vpc_flow_logs_bucket_versioning" {
  bucket = aws_s3_bucket.cafe_vpc_flow_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}