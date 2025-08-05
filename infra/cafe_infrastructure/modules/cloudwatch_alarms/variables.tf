variable "cw_high_eval_periods" {
  description = "The number of times the High CPU usage metric is evaluated for"
  type = number
  default = 2
}

variable "cw_high_cpu_eval_duration" {
  description = "The duration of time for a High CPU Usage eval period"
  type = number
  default = 60
}

variable "cw_high_cpu_threshold" {
  description = "The CPUUtil mark to watch for on instance before triggering alarm"
  type = number
  default = 75
}

variable "cw_low_eval_periods" {
  description = "The number of times the Low CPU usage metric is evaluated for"
  type = number
  default = 2
}

variable "cw_low_cpu_eval_duration" {
  description = "The duration of time for a Low CPU Usage eval period"
  type = number
  default = 60
}
  
variable "cw_low_cpu_threshold" {
  description = "The CPUUtil mark to watch for on instance before triggering alarm"
  type = number
  default = 30
}


variable "asg_name" {
  description = "The name of the autoscaling group associated to the alarm"
  type = string
}

variable "asg_scale_up_policy" {
  description = "The ARN of the scale-up policy to be triggered"
  type = string
}

variable "asg_scale_down_policy" {
  description = "The ARN of the scale-down policy to be triggered"
  type = string
}

variable "asg_sns_topic" {
  description = "The ARN of the SNS Topic through which notification is sent"
  type = string
}