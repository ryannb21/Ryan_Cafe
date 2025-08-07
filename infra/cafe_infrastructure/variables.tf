variable "aws_region" {
  description = "Desired region within which resources are provisioned"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The value of your vpc CIDR block"
  type        = string
}

variable "vpc_name" {
  description = "The desired name of your VPC"
  type        = string
}

variable "subnet_configs" {
  description = "Description found within modules/subnets/variables.tf"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
  }))
}

variable "igw_name" {
  description = "The name to identify your IGW"
  type        = string
}

variable "eip_configs" {
  description = "Description found within modules/eip/variables.tf"
  type = map(object({
    name = string
  }))
}

variable "public_subnet_keys" {
  description = <<EOF
  A list of subnet keys from subnet_configs that should host NAT Gateway
  EOF
  type        = list(string)
}

variable "app_subnet_keys" {
  description = "A list of the private app subnets"
  type        = list(string)
}

variable "db_subnet_keys" {
  description = "A list of the private db subnets"
  type        = list(string)
}

variable "public_rt_name" {
  type        = string
  description = "Name tag for the public route table"
}

variable "sg_name_prefix" {
  description = "Prefix for all security group names"
  type        = string
}

variable "main_zone_name" {
  description = "The name of your actual main domain name"
  type        = string
}

variable "sub_record_name" {
  description = "The desired name for your sub-domain name to be created"
  type        = string
}

variable "domain_name" {
  description = "The hosted zone domain name"
  type        = string
}

variable "alb_logs_bucket_name" {
  description = "Desired name of the S3 bucket for alb logs"
  type        = string
}

variable "lb_name_prefix" {
  description = "Prefix for all load balancer names"
  type        = string
  default     = "ryan-cafe"
}

variable "target_group_port" {
  description = "Desired target port for target group"
  type        = number
}

variable "health_check_interval" {
  description = "Interval in seconds between health checks"
  type        = number
  default     = 30
}

variable "sns_topic_subscriber_email" {
  description = "The desired email to subscribe to the SNS Topic"
  type        = list(string)
}

variable "cw_high_eval_periods" {
  description = "The number of times the metric is evaluated for"
  type        = number
  default     = 2
}

variable "cw_high_cpu_eval_duration" {
  description = "The duration of time for an eval period"
  type        = number
  default     = 60
}

variable "cw_high_cpu_threshold" {
  description = "The CPUUtil mark to watch for on instance before triggering alarm"
  type        = number
  default     = 75
}

variable "cw_low_eval_periods" {
  description = "The number of times the metric is evaluated for"
  type        = number
  default     = 2
}

variable "cw_low_cpu_eval_duration" {
  description = "The duration of time for an eval period"
  type        = number
  default     = 60
}

variable "cw_low_cpu_threshold" {
  description = "The CPUUtil mark to watch for on instance before triggering alarm"
  type        = number
  default     = 30
}

variable "instance_type" {
  type        = string
  description = "The instance type"
  default     = "t2.micro"
}

variable "cafe_ecr_repo_name" {
  description = "The desired name for the cafe ecr repo"
  type        = string
}

variable "flask_secret_name" {
  type = string
}

variable "email_secret_name" {
  type = string
}

variable "db_secret_name" {
  type = string
}

variable "db_identifier" {
  description = "The desired identifier for the DB"
  type        = string
  default     = "cafe-mysql-db"
}

variable "db_instance_class" {
  description = "The instance class of the db"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The desired amount of allocated storage to the db"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The desired name of the db"
  type        = string
}

variable "db_username" {
  description = "The username through which to access db"
  type        = string
}

variable "db_password" {
  description = "The desired password for the db"
  type        = string
  sensitive   = true
}

variable "secret_prefix" {
  description = "Prefix for naming the secrets"
  type        = string
}

variable "email_addr" {
  description = "Desired email through which order confirmations are sent"
  type        = string
}

variable "email_password" {
  description = "The App Password (Gmail) used alongside the email"
  type        = string
  sensitive   = true
}

variable "app_key" {
  description = "The App secret key"
  type        = string
  sensitive   = true
}

variable "blocked_ips" {
  type        = list(string)
  description = "Initial list of IPs to block (using CIDR format)"
  default     = ["45.131.108.170/32"]
}

variable "allowed_user_agent_regexes" {
  type        = list(string)
  description = "Allowed known benign user agent regexes to be exempted from blocking"
  default = [
    "InternetMeasurement\\/1\\.0",
    "CensysInspect\\/1\\.1"
  ]
}