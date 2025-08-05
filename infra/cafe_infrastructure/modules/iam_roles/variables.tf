variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_iam_role_name_combined" {
  description = "Name for the combined EC2 roles"
  type = string
  default = "CafeEC2CombinedRole"
}

variable "instance_profile_name_combined" {
  description = "Name for the combined IAM instance profile"
  type = string
  default = "CafeEC2CombinedProfile"
}


variable "secret_arns" {
  description = "A list of the secrets manager arns the role is allowed to read"
  type = list(string)
}