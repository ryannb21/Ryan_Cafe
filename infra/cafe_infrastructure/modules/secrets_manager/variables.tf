variable "secret_prefix" {
  description = "Prefix for naming the secrets"
  type = string
}

variable "db_host" {
  description = "The RDS endpoint address"
  type = string
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

variable "app_key" {
  description = <<EOF
  "The Flask secret key used to sign session cookies and CSRF tokens.
   It should be a securely generated random string (ex: `print(os.urandom(24).hex()`)).
   Please do NOT hard-code this, store as a secret or call as an env variable"
  EOF
  type = string
  sensitive = true
}