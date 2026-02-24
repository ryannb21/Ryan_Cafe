output "redis_endpoint" {
  description = "Redis cluster endpoint address"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_cluster.redis.port
}

output "redis_connection_string" {
  description = "Full Redis connection string"
  value       = "${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.port}"
}
