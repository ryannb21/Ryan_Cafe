output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.cafe_ecs_cluster.name
}

output "ecs_service_name" {
  description = "The name of the ECS Fargate service"
  value = aws_ecs_service.cafe_ecs_fargate_service.name
}