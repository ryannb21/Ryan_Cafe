aws_region = "us-east-1"

vpc_cidr_block = "10.33.0.0/16"

vpc_name = "Ryan_Cafe_VPC"

subnet_configs = {
  "Public_SN1_Cafe" = {
    cidr_block        = "10.33.1.0/24"
    availability_zone = "us-east-1a"
    public            = true
  }
  "Public_SN2_Cafe" = {
    cidr_block        = "10.33.2.0/24"
    availability_zone = "us-east-1b"
    public            = true
  }
  "Private_SN1_App_Cafe" = {
    cidr_block        = "10.33.3.0/24"
    availability_zone = "us-east-1a"
    public            = false
  }
  "Private_SN2_App_Cafe" = {
    cidr_block        = "10.33.4.0/24"
    availability_zone = "us-east-1b"
    public            = false
  }
  "Private_SN1_DB_Cafe" = {
    cidr_block        = "10.33.5.0/24"
    availability_zone = "us-east-1a"
    public            = false
  }
  "Private_SN2_DB_Cafe" = {
    cidr_block        = "10.33.6.0/24"
    availability_zone = "us-east-1b"
    public            = false
  }
}

igw_name = "Cafe_IGW"

eip_configs = {
  "Public_SN1_Cafe" = { name = "ryan_cafe_NAT_EIP_1a" }
  "Public_SN2_Cafe" = { name = "ryan_cafe_NAT_EIP_1b" }
}

public_subnet_keys = ["Public_SN1_Cafe", "Public_SN2_Cafe"]

app_subnet_keys = ["Private_SN1_App_Cafe", "Private_SN2_App_Cafe"]

db_subnet_keys = ["Private_SN1_DB_Cafe", "Private_SN2_DB_Cafe"]

public_rt_name = "Cafe_Public_RT"

sg_name_prefix = "ryan_cafe"

main_zone_name = "ryanb-lab.com"

sub_record_name = "cafe"

domain_name = "ryanb-lab.com"

lb_name_prefix = "ryan-cafe"

target_group_port = 5000

health_check_interval = 45

# sns_topic_subscriber_email = #G.A Sec

# cw_high_eval_periods = 

# cw_high_cpu_eval_duration = 

# cw_high_cpu_threshold = 

# cw_low_eval_periods = 

# cw_low_cpu_eval_duration = 

# cw_low_cpu_threshold = 

instance_type = "t2.micro"

cafe_ecr_repo_name = "ryan-cafe"

# flask_secret_name = "" #G.A Sec

# email_secret_name = "" #G.A Sec

# db_secret_name = "" #G.A Sec

db_identifier = "cafe-mysql-db"

db_instance_class = "db.t3.micro"

db_allocated_storage = 20

db_name = "cafe_orders"

# db_username = "" #G.A Sec

# db_password = "" #G.A Sec

secret_prefix = "ryan-cafev1"

# email_addr = "" #G.A Sec

# email_password = "" #G.A Sec

# app_key = "" #G.A Sec

blocked_ips = ["45.131.108.170/32"]

#All fields with "#G.A Sec represent values that are passed as secrets in GitHub Actions using TF_VAR:
#Example; Secret Name in GitHub Actions: TF_VAR_db_password, Secret Value: xxxxxxxx
#This permits this .tfvars file to be shareable, as only cafe configs are left within it, and sesnitive info
#is passed as a secret.