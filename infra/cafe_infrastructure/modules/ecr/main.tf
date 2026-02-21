resource "aws_ecr_repository" "cafe_ecr_repo" {
  for_each = var.repo_names
  
  name = each.value
  # image_scanning_configuration {
  #   scan_on_push = true
  # }
  force_delete = true

  tags = var.common_tags
}