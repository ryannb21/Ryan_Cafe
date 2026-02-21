variable "ami" {
  type = string
  description = "AMI ID to use for the instance"
}

variable "instance_type" {
  type = string
  description = "The instance type"
}

variable "instance_name" {
  description = "The name of the EC2"
  type = string
  default = "cafe-db-admin-ec2"
}

variable "subnet_id" {
  type = string
  description = "The desired subnet ID"
}

variable "security_group_ids" {
  type = list(string)
  description = "List of security group IDs"
}

variable "iam_instance_profile" {
  type = string
  description = "The IAM instance profile to be attributed to the EC2"
}

variable "spot_max_price" {
  description = "Max spot price as string."
  type = string
  default = "0.05"
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}