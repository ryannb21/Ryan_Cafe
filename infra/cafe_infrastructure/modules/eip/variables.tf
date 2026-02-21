variable "subnet_configs" {
  description = "Subnet configurations to determine AZs for EIPs"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
    tier              = string
  }))
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
