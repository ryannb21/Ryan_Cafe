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

output "public_ips" {
  value = module.eip.public_ips
  sensitive = true
}


#From modules/nat_gateway
output "nat_gateway_ids" {
  value = module.nat_gateway.nat_gateway_ids
}

output "nat_gateway_ips" {
  value = module.nat_gateway.nat_gateway_ips
  sensitive = true
}


#From modules/route_tables
output "public_route_table_id" {
  value = module.route_tables.public_route_table_id
}


#From modules/security_group
output "sg_ids" {
  value = module.security_group.sg_ids
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
output "high_cpu_alarm_id" {
  value = module.cloudwatch_alarms.high_cpu_alarm_id
}

output "low_cpu_alarm_id" {
  value = module.cloudwatch_alarms.low_cpu_alarm_id
}

output "combined_alarm_arns" {
  value = module.cloudwatch_alarms.combined_alarm_arns
}

output "combined_alarm_names" {
  value = module.cloudwatch_alarms.combined_alarm_names
}


#From modules/ec2
output "db_dedicated_ec2_instance_id" {
  value = module.ec2.db_dedicated_ec2_instance_id
}

#From modules/ecr
output "cafe_ecr_repo_url" {
  value = module.ecr.cafe_ecr_repo_url
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

output "email_secret_arn" {
  value = module.secrets_manager.email_secret_arn
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