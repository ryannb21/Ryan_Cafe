variable "vpc_id" {
  type = string
}

variable "vpc_name" {
  description = "The name of the vpc"
  type = string
}

variable "alb_security_group_id" {
  description = "The id of the load balancer security group created"
  type = string
  validation {
    condition = length(var.alb_security_group_id) > 0
    error_message = "The alb_security_group_id must be provided"
  }
}

variable "public_subnet_ids" {
  description = "The public subnet IDs for the load balancer"
  type = list(string)
  validation {
    condition = length(var.public_subnet_ids) >=2
    error_message = "You need to provide at least 2 public subnet IDs"
  }
}

variable "alb_access_logs_bucket_name" {
  description = <<EOF
  "The bucket name for the alb access logs
  (this references the dedicate bucket in s3_bucket module)"
  EOF
  type = string
  validation {
    condition = length(var.alb_access_logs_bucket_name) > 0
    error_message = "You must provide the alb_access_logs_bucket_name"
  }
}

variable "enable_deletion_protection" {
  description = "This variable controls whether delete protection is set or not for the ALB"
  type = bool
  default = false #It is imperative to turn this on in real environments. Set to false here for teardown simplicity
}

variable "target_group_port" {
  description = "Desired target port for target group"
  type = number
  validation {
    condition = var.target_group_port >= 0 && var.target_group_port <= 65535
    error_message = "Target group port must be between 0 and 65535"
  }
}

variable "target_type" {
  description = "The target type. Example: 'instance' or 'ip'"
  type = string
}

variable "health_check_path" {
  description = "Desired HTTP path for health checks"
  type = string

}

variable "health_check_interval" {
  description = "Interval in seconds between health checks"
  type = number
  validation {
    condition = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds"
  }
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate"
  type = string
  validation {
    condition = length(var.certificate_arn) > 0
    error_message = "You must provide the certificate_arn"
  }
}

variable "certificate_validation" {
  description = "The validation ID of the ACM certificate"
  type = string
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}