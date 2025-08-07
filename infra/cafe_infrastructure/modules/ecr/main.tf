resource "aws_ecr_repository" "cafe_ecr_repo" {
  name = var.cafe_ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}