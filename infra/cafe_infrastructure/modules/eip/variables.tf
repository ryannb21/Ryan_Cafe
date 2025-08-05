variable "eip_configs" {
  description = <<EOF
  Configuration for the Elastic IP addresses to be used by the NAT Gateways
  A mapping of logical EIP identifiers to configuration objects:
  EOF
  type = map(object({
    name = string
  }))
}