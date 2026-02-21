variable "vpc_id" {
  description = "The VPC where security groups will be created"
  type        = string
}

variable "vpc_name" {
  description = "VPC name for resource naming"
  type = string
}

variable "security_groups" {
  description = "Map of VPC names to their security group configurations"
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      source_sg   = optional(string)
    }))
  }))
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}