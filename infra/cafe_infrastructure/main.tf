module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
  common_tags    = var.common_tags
}

module "subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  subnet_configs = var.subnet_configs
  vpc_name       = module.vpc.vpc_name
  common_tags    = var.common_tags
}

module "igw" {
  source      = "./modules/igw"
  vpc_id      = module.vpc.vpc_id
  vpc_name    = module.vpc.vpc_name
  common_tags = var.common_tags
}

module "eip" {
  source         = "./modules/eip"
  subnet_configs = var.subnet_configs
  vpc_name       = var.vpc_name
  common_tags    = var.common_tags
}

module "nat_gateway" {
  source             = "./modules/nat_gateway"
  subnet_configs     = var.subnet_configs
  subnet_ids         = module.subnets.subnet_ids
  eip_allocation_ids = module.eip.eip_allocation_ids
  vpc_name           = var.vpc_name
  common_tags        = var.common_tags
  depends_on         = [module.eip]
}

module "route_tables" {
  source          = "./modules/route_tables"
  vpc_id          = module.vpc.vpc_id
  vpc_name        = module.vpc.vpc_name
  igw_id          = module.igw.igw_id
  subnet_configs  = module.subnets.subnet_details
  nat_gateway_ids = module.nat_gateway.nat_gateway_ids
  depends_on      = [module.igw, module.subnets, module.nat_gateway]
  common_tags     = var.common_tags
}

module "security_group" {
  source          = "./modules/security_group"
  vpc_id          = module.vpc.vpc_id
  vpc_name        = module.vpc.vpc_name
  security_groups = var.security_groups
  common_tags     = var.common_tags
}

module "vpc_endpoints" {
  source          = "./modules/vpc_endpoints"
  vpc_id          = module.vpc.vpc_id
  vpc_name        = module.vpc.vpc_name
  subnet_ids      = module.subnets.app_subnet_ids
  route_table_ids = concat(values(module.route_tables.app_route_table_ids))
  common_tags     = var.common_tags
}

module "route_53" {
  source          = "./modules/route_53"
  main_zone_name  = var.main_zone_name
  sub_record_name = var.sub_record_name
  alb_dns_name    = module.load_balancer.alb_dns_name
  alb_zone_id     = module.load_balancer.zone_id
}

module "acm_certificate" {
  source          = "./modules/acm_certificate"
  domain_name     = var.domain_name
  route53_zone_id = module.route_53.main_zone_id
}

module "s3_bucket" {
  source = "./modules/s3_bucket"
  vpc_id = module.vpc.vpc_id
}

module "load_balancer" {
  source                      = "./modules/load_balancer"
  vpc_id                      = module.vpc.vpc_id
  vpc_name                    = module.vpc.vpc_name
  alb_security_group_id       = module.security_group.security_group_ids["alb"]
  public_subnet_ids           = module.subnets.public_subnet_ids
  alb_access_logs_bucket_name = module.s3_bucket.cafe_alb_logs_bucket
  target_type                 = var.target_type
  health_check_path           = var.health_check_path
  target_group_port           = var.target_group_port
  health_check_interval       = var.health_check_interval
  certificate_arn             = module.acm_certificate.certificate_arn
  certificate_validation      = module.acm_certificate.aws_acm_certificate_validation
  common_tags                 = var.common_tags
  depends_on                  = [module.rds]
}

module "iam_roles" {
  source                    = "./modules/iam_roles"
  db_ec2_ssm_role_name      = "CafeDedicatedDBSSMRole"
  db_ec2_ssm_profile_name   = "CafeDedicatedDBSSMProfile"
  ecs_execution_role_name   = "CafeECSTaskExecutionRole"
  ecs_web_task_role_name    = "CafeECSWebTaskRole"
  ecs_orders_task_role_name = "CafeECSOrdersTaskRole"
  lambda_email_role_name    = "CafeLambdaEmailSenderRole"
  web_secret_arns           = [module.secrets_manager.app_secret_arn]
  orders_secret_arns        = [module.secrets_manager.db_secret_arn]
  order_events_queue_arn    = module.sqs_queue.order_events_queue_arn
}

module "sqs_queue" {
  source      = "./modules/sqs_queue"
  queue_name  = var.queue_name
  dlq_name    = var.dlq_name
  common_tags = var.common_tags
}

module "ses_service" {
  source              = "./modules/ses_service"
  aws_region          = var.aws_region
  domain_name         = var.domain_name
  route53_zone_id     = module.route_53.main_zone_id
  mail_from_subdomain = var.mail_from_subdomain
}

module "lambda_email_sender" {
  source                 = "./modules/lambda_email_sender"
  lambda_function_name   = var.lambda_function_name
  lambda_role_arn        = module.iam_roles.lambda_email_role_arn
  order_events_queue_arn = module.sqs_queue.order_events_queue_arn
  ses_region             = var.aws_region
  from_email             = "${var.from_email}@${var.sub_record_name}"
  reply_to               = "${var.reply_to}@${var.sub_record_name}"
  common_tags            = var.common_tags

  depends_on = [module.ses_service]
}


module "sns_topic" {
  source                     = "./modules/sns_topic"
  sns_topic_subscriber_email = var.sns_topic_subscriber_email
  common_tags                = var.common_tags
}

module "cloudwatch_alarms" {
  source                  = "./modules/cloudwatch_alarms"
  aws_region = var.aws_region
  dashboard_name          = var.dashboard_name
  sns_topic_arn           = module.sns_topic.sns_topic_arn
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  web_service_name        = module.ecs.web_service_name
  orders_service_name     = module.ecs.order_service_name
  alb_arn_suffix          = module.load_balancer.alb_arn_suffix
  target_group_arn_suffix = module.load_balancer.target_group_arn_suffix
  lambda_function_name    = module.lambda_email_sender.lambda_name
  order_events_queue_name = module.sqs_queue.order_events_queue_name
  order_events_dlq_name   = module.sqs_queue.order_events_dlq_name
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = data.aws_ami.ec2_ami.id
  instance_type        = var.instance_type
  iam_instance_profile = module.iam_roles.db_ec2_ssm_profile_name
  subnet_id            = module.subnets.app_subnet_ids[0]
  security_group_ids   = [module.security_group.security_group_ids["db_admin_ec2"]]
  common_tags          = var.common_tags
}

module "ecr" {
  source      = "./modules/ecr"
  repo_names  = var.repo_names
  common_tags = var.common_tags
}

module "ecs" {
  source                           = "./modules/ecs"
  aws_region                       = var.aws_region
  vpc_id                           = module.vpc.vpc_id
  family                           = var.family
  ecs_cluster_name                 = var.ecs_cluster_name
  ecs_log_group_name               = var.ecs_log_group_name
  service_discovery_namespace_name = var.service_discovery_namespace_name
  ecs_execution_role_arn           = module.iam_roles.ecs_execution_role_arn
  ecs_web_task_role_arn            = module.iam_roles.ecs_web_task_role_arn
  ecs_orders_task_role_arn         = module.iam_roles.ecs_orders_tasks_role_arn
  web_image                        = "${module.ecr.repo_urls["web"]}:latest"
  orders_image                     = "${module.ecr.repo_urls["orders"]}:latest"
  app_subnet_ids                   = module.subnets.app_subnet_ids
  web_security_group_ids           = [module.security_group.security_group_ids["ecs_web_frontend"]]
  orders_security_group_ids        = [module.security_group.security_group_ids["ecs_order_service"]]
  web_target_group_arn             = module.load_balancer.target_group_arn
  flask_secret_name                = module.secrets_manager.app_secret_name
  db_secret_name                   = module.secrets_manager.db_secret_name
  order_events_queue_url           = module.sqs_queue.order_events_queue_url
  redis_endpoint                   = module.redis.redis_endpoint
  redis_port                       = module.redis.redis_port
  depends_on                       = [module.ecr, module.load_balancer, module.iam_roles, module.sqs_queue, module.redis]
}

module "rds" {
  source               = "./modules/rds"
  subnet_ids           = module.subnets.db_subnet_ids
  db_security_group_id = [module.security_group.security_group_ids["database"]]
  db_identifier        = var.db_identifier
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  vpc_name             = module.vpc.vpc_name
  common_tags          = var.common_tags
}

module "redis" {
  source              = "./modules/redis"
  cluster_id          = var.redis_cluster_id
  node_type           = var.redis_node_type
  subnet_group_name   = var.redis_subnet_group_name
  subnet_ids          = module.subnets.app_subnet_ids
  security_group_id   = module.security_group.security_group_ids["redis"]
  common_tags         = var.common_tags
}

module "secrets_manager" {
  source        = "./modules/secrets_manager"
  secret_prefix = var.secret_prefix
  db_host       = module.rds.rds_endpoint
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = var.db_password
  app_key       = var.app_key
}

module "waf" {
  source                     = "./modules/waf"
  cafe_waf_prefix            = var.cafe_waf_prefix
  waf_scope                  = var.waf_scope
  alb_arn                    = module.load_balancer.alb_arn
  blocked_ips                = var.blocked_ips
  allowed_user_agent_regexes = var.allowed_user_agent_regexes
  depends_on                 = [module.load_balancer]
}