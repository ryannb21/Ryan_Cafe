variable "cafe_waf_prefix" {
  type        = string
  description = "The name prefix associated with all WAF resources"
}

variable "alb_arn" {
  type        = string
  description = "The ARN of the ALB to associate with the WAF"
}

variable "waf_scope" {
  type        = string
  description = "The scope for the WAF"
}

variable "blocked_ips" {
  type        = list(string)
  description = "Initial list of IPs to block (using CIDR format)"
  default     = []
}

variable "allowed_user_agent_regexes" {
  type        = list(string)
  description = "Allowed known benign user agent regexes to be exempted from blocking"
  default     = [
    "InternetMeasurement/1\\.0",
    "CensysInspect/1\\.1"
  ]
}