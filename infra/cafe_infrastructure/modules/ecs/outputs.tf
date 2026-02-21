output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value = aws_ecs_cluster.cafe_ecs_cluster.name
}

output "web_service_name" {
  description = "The web service name"
  value = aws_ecs_service.web_service.name
}

output "order_service_name" {
  description = "Orders service name"
  value = aws_ecs_service.orders_service.name
}

output "service_discovery_namespace" {
  description = "Private namespace used for service discovery"
  value = aws_service_discovery_private_dns_namespace.cafe_ns.name
}