# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
  tags       = var.common_tags
}

# ElastiCache Replication Group (Redis 6.2)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = var.cluster_id
  description                = "Redis replication group for Valkey upgrade"
  engine                     = "redis"
  engine_version             = "6.2"
  node_type                  = var.node_type
  num_cache_clusters         = 1
  parameter_group_name       = "default.redis6.x"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids         = [var.security_group_id]
  automatic_failover_enabled = false
  
  tags = var.common_tags
}
