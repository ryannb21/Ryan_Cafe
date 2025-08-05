variable "vpc_id" {
  description = "The VPC where security groups will be created"
  type        = string
}

variable "sg_name_prefix" {
  description = "Prefix for all security group names"
  type        = string
  default     = "ryan_cafe"
  validation {
    condition = length(var.sg_name_prefix) > 0
    error_message = "Your security group name prefix cannot be empty."
  }
}