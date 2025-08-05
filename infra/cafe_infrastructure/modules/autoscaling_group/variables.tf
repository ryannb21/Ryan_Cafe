variable "asg_name_prefix" {
  description = "Prefix for all load balancer names"
  type = string
  default = "Cafe_App"
}

variable "asg_instance_type" {
  description = "The desired instance type"
  type = string
  default = "t2.micro"
}

variable "db_endpoint" {
  description = "The RDS endpoint to be used by the launch template"
  type = string
}

variable "ami_id" {
  description = "The EC2 instance ami"
  type = string
}

variable "asg_security_group_ids" {
  description = "List of SG IDs to attach to the instances"
  type = list(string)
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type = number
  default = 2
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type = number
  default = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type = number
  default = 3
}

variable "subnet_ids" {
  description = "List of the subnet IDs for the ASG"
  type = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group for health checks and registeration"
  type = string
}


variable "asg_up_scaling_adjustment" {
  description = "Value to increase scaling by ASG"
  type = number
  default = 1
}

variable "asg_down_scaling_adjustment" {
  description = "Value to decrease scaling by ASG"
  type = number
  default = -1
}

variable "instance_profile_name" {
  description = "IAM instance profile name to be attached to EC2"
  type = string
}

variable "sns_topic_arn" {
  description = "The ARN of the created SNS Topic"
  type = string
}