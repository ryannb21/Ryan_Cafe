variable "alb_logs_bucket_name" {
  description = "Desired name of the S3 bucket for alb logs"
  type = string
  default = "cafe-alb-logs"
}