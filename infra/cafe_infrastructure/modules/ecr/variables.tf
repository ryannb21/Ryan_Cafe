variable "repo_names" {
  description = "Map of repo keys to repo names"
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags for resources"
  type = map(string)
  default = {}
}