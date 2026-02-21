output "repo_urls" {
  value = {for k, v in aws_ecr_repository.cafe_ecr_repo : k => v.repository_url}
}