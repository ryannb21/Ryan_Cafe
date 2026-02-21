variable "vpc_id" {
  description = "The ID of the vpc you want the IGW attached to"
  type = string
}

variable "vpc_name" {
  description = "The name of the vpc"
  type = string
}

variable "common_tags" {
  description = "Common tags for each resource"
  type = map(string)
  default = {}
}