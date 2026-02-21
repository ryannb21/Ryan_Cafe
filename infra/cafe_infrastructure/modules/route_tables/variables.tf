variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_name" {
  description = "Name of the parent VPC for route table naming"
  type = string
}

variable "igw_id" {
  type        = string
  description = "The Internet Gateway ID"
}

variable "subnet_configs" {
  description = "Map of subnet configurations with their details including tier"
  type = map(object({
    subnet_id         = string
    availability_zone = string
    public            = bool
    tier              = string
  }))
}

variable "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs by AZ"
  type = map(string)
  default = {}
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}