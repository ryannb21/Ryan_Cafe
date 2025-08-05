variable "db_identifier" {
  description = "The desired identifier for the DB"
  type = string
  default = "cafe-mysql-db"
}

variable "db_instance_class" {
  description = "The instance class of the db"
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The desired amount of allocated storage to the db"
  type = number
  default = 20
}

variable "subnet_ids" {
  description = "List of the subnet IDs for the RDS"
  type = list(string)
}

variable "db_security_group_id" {
  description = "List of SG IDs to attach to the instances"
  type = list(string)
}

variable "db_name" {
  description = "The desired name of the db"
  type = string
  validation {
    condition = length(var.db_name) > 0
    error_message = "Your db_name cannot be empty"
  }
}

variable "db_username" {
  description = "The username through which to access db"
  type = string
  validation {
    condition = length(var.db_username) > 0
    error_message = "Your db_username cannot be empty"
  }
}

variable "db_password" {
  description = "The desired password for the db"
  type = string
  sensitive = true
  validation {
    condition = length(var.db_password) >= 8
    error_message = "Your db_password should be 8 characters minimum"
  }
}