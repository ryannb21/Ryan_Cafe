variable "vpc_id" {
  description = "The ID of the VPC for the flow logs"
  type = string
}
variable "alb_logs_bucket_name" {
  description = "Desired name of the S3 bucket for alb logs"
  type = string
  default = "cafe-alb-logs"
}

variable "vpc_flow_logs_bucket_name" {
  description = "Desired name of the S3 bucket for vpc flow logs"
  type = string
  default = "cafe-vpc-flow-logs"
}