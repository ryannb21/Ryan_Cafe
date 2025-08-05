variable "subnet_configs" {
  description = <<EOF
  A mapping of the subnets to their objects:
  - cidr_block (string) = the desired CIDR block
  - availability_zone (String) = desired AZ for the subnet
  - public (bool) = true/false depending on desire for pub/priv SN
  EOF
  type = map(object({
    cidr_block = string
    availability_zone = string
    public = bool
  }))
  validation {
    condition = alltrue([for cfg in values (var.subnet_configs) : can(cidrnetmask(cfg.cidr_block))])
    error_message = "All subnets_configs.cidr_block must be valid CIDR blocks."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}