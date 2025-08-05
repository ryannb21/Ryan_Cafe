variable "main_zone_name" {
  description = "The name of your actual main domain name"
  type = string
}

variable "sub_record_name" {
  description = "The desired name for your sub-domain name to be created"
  type = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type = string
}

variable "alb_zone_id" {
  description = "The Route 53 zone ID of the ALB"
  type = string
}