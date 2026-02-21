#General Variables
aws_region = "us-east-1"

common_tags = {
  "Environment" = "Cafe"
  "Project"     = "Ryan-Cafe"
  "Owner"       = "Ryan-B"
}

#VPC Variables
vpc_cidr_block = "10.33.0.0/16"

vpc_name = "Ryan-Cafe"

#Subnet Variables/Config
subnet_configs = {
  "Public-1a" = {
    cidr_block        = "10.33.1.0/24"
    availability_zone = "us-east-1a"
    public            = true
    tier              = "public"
  }
  "Public-1b" = {
    cidr_block        = "10.33.2.0/24"
    availability_zone = "us-east-1b"
    public            = true
    tier              = "public"
  }
  "App-1a" = {
    cidr_block        = "10.33.10.0/24"
    availability_zone = "us-east-1a"
    public            = false
    tier              = "app"
  }
  "App-1b" = {
    cidr_block        = "10.33.11.0/24"
    availability_zone = "us-east-1b"
    public            = false
    tier              = "app"
  }
  "DB-1a" = {
    cidr_block        = "10.33.20.0/24"
    availability_zone = "us-east-1a"
    public            = false
    tier              = "db"
  }
  "DB-1b" = {
    cidr_block        = "10.33.21.0/24"
    availability_zone = "us-east-1b"
    public            = false
    tier              = "db"
  }
}

#Security Group Variables/Config
security_groups = {
  "alb" = {
    description = "Allow HTTP/HTTPS from the internet"
    ingress_rules = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], source_sg = null },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], source_sg = null }
    ]
  }
  "ecs_web_frontend" = {
    description = "Allow traffic from ALB"
    ingress_rules = [
      { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = null, source_sg = "alb" }
    ]
  }
  "ecs_order_service" = {
    description = "Allows traffic from the ecs_web_frontend"
    ingress_rules = [
      { from_port = 5001, to_port = 5001, protocol = "tcp", cidr_blocks = null, source_sg = "ecs_web_frontend" }
    ]
  }
  "db_admin_ec2" = {
    description   = "Allows no inbound traffic, solely for DB admin work via SSM"
    ingress_rules = []
  }
  "database" = {
    description = "Allows MySQL from the admin SG and ECS order service"
    ingress_rules = [
      { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = null, source_sg = "ecs_order_service" },
      { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = null, source_sg = "db_admin_ec2" }
    ]
  }
}

#Route53 Variables
main_zone_name = "ryan-lab.com"

sub_record_name = "cafe.ryan-lab.com"

#ACM_Certificate Variables
domain_name = "ryan-lab.com"

#Load Balancer Variables
target_group_port = 5000

target_type = "ip"

health_check_path = "/health"

health_check_interval = 45

#SQS_Queue Variables
queue_name = "cafe-order-events-queue"

dlq_name = "cafe-order-events-dlq"

#SES_Service Variables
mail_from_subdomain = "mail"

#Lambda Variables
lambda_function_name = "cafe-email-sender"

from_email = "orders"

reply_to = "support"

#SNS_Topic Variables
sns_topic_subscriber_email = [] #G.A Sec

#CloudWatch Variables
dashboard_name = "Cafe-Ops-Dashboard"

# cw_high_eval_periods = 

# cw_high_cpu_eval_duration = 

# cw_high_cpu_threshold = 


### EC2 Variables ###
instance_type = "t2.micro"

#ECR Variables
repo_names = {
  web    = "ryan-cafe-web"
  orders = "ryan-cafe-orders"
}

#ECS Variables
family = "ryan-cafe"

ecs_cluster_name = "cafe-ecs-cluster"

ecs_log_group_name = "/aws/ecs/ryan-cafe"

service_discovery_namespace_name = "cafe.local"

#RDS Variables
db_identifier = "cafe-mysql-db"

db_instance_class = "db.t3.micro"

db_allocated_storage = 20

db_name = "cafe_orders"

db_username = "" #G.A Sec

db_password = "" #G.A Sec

#Secrets Manager Variables
secret_prefix = "ryan-cafev82"

app_key = "" #G.A Sec

#WAF Variables
cafe_waf_prefix = "cafe_waf"

waf_scope = "REGIONAL"

blocked_ips = ["45.131.108.170/32"]

allowed_user_agent_regexes = ["InternetMeasurement/1\\.0", "CensysInspect/1\\.1"]

#All fields with "#G.A Sec represent values that are passed as secrets in GitHub Actions using TF_VAR:
#Example; Secret Name in GitHub Actions: TF_VAR_db_password, Secret Value: xxxxxxxx
#This permits this .tfvars file to be shareable, as only cafe configs are left within it, and sesnitive info
#is passed as a secret.