variable "nat_gateway_configs" {
  description = <<EOF
  A mapping of the logical NAT Gateway keys to objects with:
  - allocation_id (string): EIP allocation ID to be attached
  - subnet_ID (string): SUbnet ID in which to create the NAT Gateway
  EOF
  type = map(object({
    allocation_id = string
    subnet_id = string
  }))
}