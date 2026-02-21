variable "vpc_cidr_block" {
  description = "The value of your vpc CIDR block"
  type = string
  validation {
    condition = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "You must enter a valid CIDR block."
  }
}

variable "vpc_name" {
  description = "The desired name of your VPC"
  type = string
  default = "Ryan_Cafe"
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}