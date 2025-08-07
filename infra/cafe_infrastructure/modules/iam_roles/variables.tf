variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_ec2_ssm_role_name" {
  description = "The role name for the dedicated db ec2"
  type = string
  default = "CafeDedicatedDBSSMRole"
}

variable "db_ec2_ssm_profile_name" {
  description = "Name of the db EC2 Instance Profile"
  type = string
  default = "CafeDedicatedDBSSMProfile"
}

variable "secret_arns" {
  description = "A list of the secrets manager arns the role is allowed to read"
  type = list(string)
}

variable "aws_ecs_task_iam_role_name" {
  description = "Name for the ECS Task role"
}