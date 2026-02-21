variable "subnet_configs" {
  description = "Subnet configurations to determine AZs and public subnets"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
    tier              = string
  }))
}

variable "subnet_ids" {
  description = "Map of subnet names to IDs"
  type = map(string)
}

variable "eip_allocation_ids" {
  description = "Map of EIP allocation IDs by AZ"
  type = map(string)
}

variable "vpc_name" {
  description = "VPC name for tagging"
  type = string
}

variable "common_tags" {
  description = "Common tags for resources"
  type = map(string)
  default = {}
}
