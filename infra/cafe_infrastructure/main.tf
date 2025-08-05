module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
}

module "subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  subnet_configs = var.subnet_configs
}

module "igw" {
  source   = "./modules/igw"
  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
}

module "eip" {
  source      = "./modules/eip"
  eip_configs = var.eip_configs
}

module "nat_gateway" {
  source              = "./modules/nat_gateway"
  nat_gateway_configs = local.nat_gateway_configs
  depends_on          = [module.eip, module.subnets]
}

module "route_tables" {
  source            = "./modules/route_tables"
  vpc_id            = module.vpc.vpc_id
  igw_id            = module.igw.igw_id
  nat_gateway_ids   = local.private_to_nat
  public_subnet_ids = local.public_subnet_ids
  app_subnet_ids    = local.app_subnet_ids
  db_subnet_ids     = local.db_subnet_ids
  public_rt_name    = var.public_rt_name
  depends_on        = [module.igw, module.nat_gateway, module.subnets]
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
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
  source               = "./modules/s3_bucket"
  alb_logs_bucket_name = var.alb_logs_bucket_name
}

module "load_balancer" {
  source                      = "./modules/load_balancer"
  vpc_id                      = module.vpc.vpc_id
  lb_name_prefix              = var.lb_name_prefix
  alb_security_group_id       = module.security_group.sg_ids.cafe_alb_sg
  public_subnet_ids           = values(local.public_subnet_ids)
  alb_access_logs_bucket_name = module.s3_bucket.cafe_alb_logs_bucket
  target_group_port           = var.target_group_port
  health_check_interval       = var.health_check_interval
  certificate_arn             = module.acm_certificate.certificate_arn
  certificate_validation      = module.acm_certificate.aws_acm_certificate_validation
  depends_on                  = [module.rds]
}

module "autoscaling_group" {
  source                      = "./modules/autoscaling_group"
  db_endpoint                 = module.rds.rds_endpoint
  ami_id                      = data.aws_ami.ec2_ami.id
  instance_profile_name       = module.iam_roles.combined_instance_profile_name
  asg_name_prefix             = var.asg_name_prefix
  asg_security_group_ids      = [module.security_group.sg_ids["cafe_app_sg"]]
  subnet_ids                  = values(local.app_subnet_ids)
  target_group_arn            = module.load_balancer.target_group_arn
  asg_min_size                = var.asg_min_size
  asg_max_size                = var.asg_max_size
  asg_desired_capacity        = var.asg_desired_capacity
  asg_up_scaling_adjustment   = var.asg_up_scaling_adjustment
  asg_down_scaling_adjustment = var.asg_down_scaling_adjustment
  sns_topic_arn               = module.sns_topic.sns_topic_arn
  depends_on                  = [module.load_balancer]
}

module "iam_roles" {
  source = "./modules/iam_roles"
  secret_arns = [
    module.secrets_manager.db_secret_arn,
    module.secrets_manager.email_secret_arn,
    module.secrets_manager.app_secret_arn
  ]
  aws_iam_role_name_combined     = "EC2CombinedRole"
  instance_profile_name_combined = "EC2CombinedInstanceProfile"
}

module "sns_topic" {
  source                     = "./modules/sns_topic"
  sns_topic_subscriber_email = var.sns_topic_subscriber_email
}

module "cloudwatch_alarms" {
  source                    = "./modules/cloudwatch_alarms"
  asg_name                  = module.autoscaling_group.autoscaling_group_name
  asg_scale_up_policy       = module.autoscaling_group.scale_up_policy_arn
  asg_scale_down_policy     = module.autoscaling_group.scale_down_policy_arn
  asg_sns_topic             = module.sns_topic.sns_topic_arn
  cw_high_cpu_eval_duration = var.cw_high_cpu_eval_duration
  cw_high_eval_periods      = var.cw_high_eval_periods
  cw_high_cpu_threshold     = var.cw_high_cpu_threshold
  cw_low_cpu_eval_duration  = var.cw_low_cpu_eval_duration
  cw_low_eval_periods       = var.cw_low_eval_periods
  cw_low_cpu_threshold      = var.cw_low_cpu_threshold
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = data.aws_ami.ec2_ami.id
  instance_type        = var.instance_type
  iam_instance_profile = module.iam_roles.combined_instance_profile_name
  subnet_id            = values(local.app_subnet_ids)[0]
  security_group_ids   = [module.security_group.sg_ids["cafe_app_sg"]]
}

module "rds" {
  source               = "./modules/rds"
  subnet_ids           = values(local.db_subnet_ids)
  db_security_group_id = [module.security_group.sg_ids["cafe_db_sg"]]
  db_identifier        = var.db_identifier
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
}

module "secrets_manager" {
  source         = "./modules/secrets_manager"
  secret_prefix  = var.secret_prefix
  db_host        = module.rds.rds_endpoint
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  email_addr     = var.email_addr
  email_password = var.email_password
  app_key        = var.app_key
}

module "waf" {
  source      = "./modules/waf"
  alb_arn     = module.load_balancer.alb_arn
  blocked_ips = ["45.131.108.170/32"]
  allowed_user_agent_regexes = [
    "InternetMeasurement/1\\.0",
    "CensysInspect/1.\\.1"
  ]
  depends_on = [module.load_balancer]
}