variable "ami" {
  type = string
  description = "AMI ID to use for the instance"
}

variable "instance_type" {
  type = string
  description = "The instance type"
  default = "t2.micro"
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