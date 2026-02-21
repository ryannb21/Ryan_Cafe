variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_name" {
  description = "Name of the parent VPC for route table naming"
  type = string
}

variable "route_table_ids" {
  type = list(string)
  description = "The route tables attached to the VPC Endpoints"
}

variable "subnet_ids" {
  type = list(string)
  description = "The subnets attached to the VPC Endpoints"
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}