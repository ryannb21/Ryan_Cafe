# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
  tags       = var.common_tags
}

# ElastiCache Redis 6.2 Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  engine_version       = "6.2"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.security_group_id]
  
  tags = var.common_tags
}
