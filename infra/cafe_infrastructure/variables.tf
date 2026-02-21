#General Variables
variable "aws_region" {
  description = "Desired region within which resources are provisioned"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to each resource"
  type        = map(string)
  default     = {}
}

#VPC Variables
variable "vpc_cidr_block" {
  description = "The value of your vpc CIDR block"
  type        = string
}

variable "vpc_name" {
  description = "The desired name of your VPC"
  type        = string
}

#Subnet Variables
variable "subnet_configs" {
  description = "Description found within modules/subnets/variables.tf"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
    tier              = string
  }))
}

#Security Group Variables/Config
variable "security_groups" {
  description = "Map of VPC names to their security group configurations"
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      source_sg   = optional(string)
    }))
  }))
}

#Route53 Variables
variable "main_zone_name" {
  description = "The name of your actual main domain name"
  type        = string
}

variable "sub_record_name" {
  description = "The desired name for your sub-domain name to be created"
  type        = string
}

#ACM_Certificate Variables
variable "domain_name" {
  description = "The hosted zone domain name"
  type        = string
}

#Load Balancer Variables
variable "target_group_port" {
  description = "Desired target port for target group"
  type        = number
}

variable "target_type" {
  description = "The target type. Example: 'instance' or 'ip'"
  type        = string
}

variable "health_check_path" {
  description = "Desired HTTP path for health checks"
  type        = string
}

variable "health_check_interval" {
  description = "Interval in seconds between health checks"
  type        = number
}

#SQS_Queue Variables
variable "queue_name" {
  description = "Name of the main order events queue"
  type        = string
}

variable "dlq_name" {
  description = "Name of the dead-letter queue"
  type        = string
}

#SES_Service Variables
variable "mail_from_subdomain" {
  description = "Subdomain for MAIL FROM"
  type        = string
}

#Lambda Variables
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "from_email" {
  description = "Verified FROM address under the SES-verified domain (e.g. orders@ryanb-lab.com)"
  type        = string
}

variable "reply_to" {
  description = "Optional reply-to address"
  type        = string
}

#SNS_Topic Variables
variable "sns_topic_subscriber_email" {
  description = "The desired email to subscribe to the SNS Topic"
  type        = list(string)
}

#CloudWatch Variables
variable "dashboard_name" {
  description = "The CloudWatch dashboard name"
  type        = string
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

# EC2 Variables
variable "instance_type" {
  type        = string
  description = "The instance type"
  default     = "t2.micro"
}

#ECR Variables
variable "repo_names" {
  description = "Map of repo keys to repo names"
  type        = map(string)
}

#ECS Variables
variable "family" {
  description = "Base name used for ECS family/service names"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "service_discovery_namespace_name" {
  description = "Private DNS namespace name"
  type        = string
}

#RDS Variables
variable "db_identifier" {
  description = "The desired identifier for the DB"
  type        = string
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

#Secrets Manager Variables
variable "secret_prefix" {
  description = "Prefix for naming the secrets"
  type        = string
}

variable "app_key" {
  description = "The App secret key"
  type        = string
  sensitive   = true
}

#WAF Variables
variable "cafe_waf_prefix" {
  type        = string
  description = "The name prefix associated with all WAF resources"
}

variable "waf_scope" {
  type        = string
  description = "The scope for the WAF"
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