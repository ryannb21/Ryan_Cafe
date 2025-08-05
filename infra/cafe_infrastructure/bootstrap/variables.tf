variable "aws_region" {
  description = "Desired AWS region for resource provisioning"
  type = string
  default = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type = string
  default = "cafe-tf-state"
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB tables for State Locking"
  type = string
  default = "cafe-lock"
}