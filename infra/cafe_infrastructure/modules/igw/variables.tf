variable "vpc_id" {
  description = "The ID of the vpc you want the IGW attached to"
  type = string
}

variable "igw_name" {
  description = "The name to identify your IGW"
  type = string
  default = "Cafe_IGW"
}