variable "cluster_id" {
  description = "ElastiCache cluster identifier"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t4g.micro"
}

variable "subnet_group_name" {
  description = "Name for the ElastiCache subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ElastiCache"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Redis cluster"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
