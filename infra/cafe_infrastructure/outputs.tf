#From modules/vpc
output "vpc_id" {
  value = module.vpc.vpc_id
}


#From modules/subnets
output "subnet_ids" {
  value = module.subnets.subnet_ids
}


#From modules/igw
output "igw_id" {
  value = module.igw.igw_id
}

#From modules/eip
output "eip_allocation_ids" {
  value = module.eip.eip_allocation_ids
}


#From modules/route_tables
output "public_route_table_id" {
  value = module.route_tables.public_route_table_id
}


#From modules/security_group
output "sg_ids" {
  value = module.security_group.security_group_ids
}


#From modules/route_53
output "main_zone_id" {
  value = module.route_53.main_zone_id
}

output "subdomain_fqdn" {
  value = module.route_53.subdomain_fqdn
}

output "subdomain_zone_id" {
  value = module.route_53.subdomain_zone_id
}


#From modules/acm_certificate
output "certificate_arn" {
  value = module.acm_certificate.certificate_arn
}

output "certificate_id" {
  value = module.acm_certificate.certificate_id
}

output "aws_acm_certificate_validation" {
  value = module.acm_certificate.aws_acm_certificate_validation
}


#From modules/s3_bucket
output "cafe_alb_logs_bucket_arn" {
  value = module.s3_bucket.cafe_alb_logs_bucket_arn
}

output "cafe_vpc_flow_logs_bucket_arn" {
  value = module.s3_bucket.cafe_vpc_flow_logs_bucket_arn
}


#From modules/load_balancer
output "alb_arn" {
  value = module.load_balancer.alb_arn
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}


#From modules/sns_topic
output "sns_topic_name" {
  value = module.sns_topic.sns_topic_name
}

output "sns_topic_arn" {
  value = module.sns_topic.sns_topic_arn
}


#From modules/cloudwatch_alarms
output "combined_alarm_arns" {
  value = keys(module.cloudwatch_alarms.alarm_arns)
}


#From modules/ec2
output "db_admin_instance_id" {
  value = module.ec2.db_admin_instance_id
}

#From modules/ecr
output "ecr_repo_urls" {
  value = module.ecr.repo_urls
}


#From modules/rds
output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_arn" {
  value = module.rds.rds_arn
}


#From modules/secrets_manager
output "db_secret_arn" {
  value = module.secrets_manager.db_secret_arn
}

output "app_secret_arn" {
  value = module.secrets_manager.app_secret_arn
}


#From modules/waf
output "cafe_waf_acl_id" {
  value = module.waf.cafe_waf_acl_id
}

output "cafe_waf_acl_arn" {
  value = module.waf.cafe_waf_acl_arn
}