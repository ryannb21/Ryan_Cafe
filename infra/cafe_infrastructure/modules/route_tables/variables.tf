variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "igw_id" {
  type        = string
  description = "The Internet Gateway ID"
}

variable "public_subnet_ids" {
  type        = map(string)
  description = "Map of public subnet keys → subnet IDs"
  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "You must provide at least one public subnet"
  }
}

variable "app_subnet_ids" {
  type        = map(string)
  description = "Map of private-app subnet keys → subnet IDs"
}

variable "db_subnet_ids" {
  type        = map(string)
  description = "Map of private-db subnet keys → subnet IDs"
}

variable "nat_gateway_ids" {
  type        = map(string)
  description = "Map of NAT gateway keys → allocation IDs"
  validation {
    condition     = length(var.nat_gateway_ids) > 0
    error_message = "You must provide at least one NAT gateway"
  }
}

variable "public_rt_name" {
  type        = string
  description = "Name tag for the public route table"
  default = "Cafe_Public_RT"
}