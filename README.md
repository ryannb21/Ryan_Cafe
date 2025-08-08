# Ryan's Cafe - A Cloud-Native Web Application

# DISCLAIMER: THIS IS A PERSONAL PROJECT, NO "ORDERS" PLACED VIA THE WEBSITE WILL BE DELIVERED! THANKS FOR UNDERSTANDING.

This is a production-ready cafe ordering system built with modern DevOps practices accounted for; featuring automated CI/CD, containerization, and enterprise-grade AWS infrastructure.
===

## Live Demo
Feel free to place an order via the website:
**Website:** [https://cafe.ryanb-lab.com](https://cafe.ryanb-lab.com)
====

## Architecture Overview

### **Application Stack**
- **Frontend:** HTML5, CSS3, JavaScript
- **Backend:** Python Flask with security headers & CSRF protection
- **Database:** Amazon RDS MySQL with spanning multi-AZs, automated backups and encrypted storage
- **Email:** SMTP integration for order confirmations

### **Infrastructure & DevOps**
- **Containerization:** Docker with multi-stage builds
- **Container Registry:** Amazon ECR
- **Orchestration:** Amazon ECS Fargate (serverless containers)
- **Load Balancing:** Application Load Balancer with SSL termination
- **Auto Scaling:** ECS Target tracking based on CPU utilization metrics
- **CI/CD:** GitHub Actions with automated deployment
- **Infrastructure as Code:** Terraform with modular architecture
- **State Management:** S3 backend with DynamoDB for state locking

### **Security & Monitoring**
- **Web Application Firewall:** AWS WAF with IP blocking, bot protection, rate limiting, and known exploit paths blocking
- **SSL/TLS:** AWS Certificate Manager
- **Secrets Management:** AWS Secrets Manager for sensitive data
- **Security Headers:** HSTS, CSP, X-Frame-Options, XSS Protection
- **Monitoring:** CloudWatch metrics and alarms, Application Load Balancer access logs & VPC flow logs stored in S3.
- **Alerting:** SNS notifications for infrastructure events
- **Access Control:** IAM roles with least privilege principle

### **High Availability & Performance**
- **Multi-AZ Deployment:** Resources distributed across 2 availability zones
- **Auto Scaling:** Responsive to traffic patterns (1-10 containers)
- **Health Checks:** Application and infrastructure level monitoring
- **Database:** RDS with automated backups and point-in-time recovery
- **CDN Ready:** Architecture supports CloudFront integration (when implemented)
===

## Technology Stack

| Category | Technology |
|----------|------------|
| **Application** | Python Flask, MySQL, HTML/CSS/JS |
| **Containerization** | Docker, Amazon ECR |
| **Orchestration** | Amazon ECS Fargate |
| **Infrastructure** | Terraform, AWS (VPC, ALB, RDS, Route53) |
| **CI/CD** | GitHub Actions |
| **Security** | AWS WAF, ACM, Secrets Manager |
| **Monitoring** | CloudWatch, SNS, ALB & VPC Logs|


## Deployment

### **Automated Deployment (Recommended)**
1. Fork this repository
2. Configure GitHub Secrets (see the "Configuration" section)
3. Push to `main` branch - deployment set to occur automatically

### **Manual Deployment (via Terminal)**
```bash
#Deploying the infrastructure
cd infra/cafe_infrastructure/bootstrap
terraform init && terraform apply

#Getting the outputs and configuring backend
cd ..
terraform init -backend-config="bucket=OUTPUT_BUCKET" -backend-config="dynamodb_table=OUTPUT_TABLE"
terraform apply
```

## Configuration

### **Required GitHub Secrets**
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
ECR_REGISTRY (This will be in the format: <aws_account_number>.dkr.ecr.<aws_region>.amazonaws.com ||e.g: 123456789.dkr.ecr.us-east-2.amazonaws.com)
TF_VAR_db_password
TF_VAR_db_username
TF_VAR_sns_topic_subscriber_email
TF_VAR_email_addr
TF_VAR_email_password
TF_VAR_app_key
TF_VAR_flask_secret_name
TF_VAR_email_secret_name
TF_VAR_db_secret_name
```

### **Infrastructure Customization**
If you choose to re-use this infrastructure, simply edit `infra/cafe_infrastructure/terraform.tfvars` to customize the following variables:
- VPC CIDR blocks and subnets
- Domain names and SSL certificates
- Instance types and scaling parameters
- Monitoring thresholds
===

## Project Structure
```
├── app/ryan_cafe_app/          # Flask application
│   ├── static/                 # CSS, images, JS
│   ├── templates/              # HTML templates
│   ├── app.py                  # Main application
│   ├── Dockerfile              # Container configuration
│   └── requirements.txt        # Python dependencies
├── infra/cafe_infrastructure/  # Infrastructure as Code
│   ├── bootstrap/              # S3 backend & DynamoDB setup
│   ├── modules/                # All reusable Terraform modules
│   │   ├── vpc/               # Virtual Private Cloud
│   │   ├── ecs/               # Container orchestration
│   │   ├── rds/               # Database
│   │   ├── load_balancer/     # Application Load Balancer
│   │   └── ...                # Additional modules
│   ├── main.tf                # Main infrastructure
│   └── terraform.tfvars       # Configuration variables
└── .github/workflows/          # CI/CD pipelines
    ├── deploy.yml             # Automated deployment in GitHub Actions
    └── destroy.yml            # Infrastructure teardown via GitHub Actions
```

## CI/CD Pipeline

### **Deployment Workflow**
1. **Code Push** → This triggers GitHub Actions
2. **Infrastructure** → Terraform creates/updates AWS resources
3. **Container Build** → Docker image gets built and pushed to ECR
4. **Deployment** → ECS service gets updated with new container
5. **Health Checks** → Automated verification of deployment

### **Features**
- Automated deployment
- Zero-downtime deployments
- Manual destroy workflow for cleanup
===

## Security Features
- **Full HTTPS:** SSL/TLS encryption for all traffic, and HTTP -> HTTPS redirection.
- **Web Application Firewall:** Protection against known common attacks, bots. Includes rate-limiting, and common exploit paths blocking.
- **Secrets Management:** Sensitive information is securely stored via Secrets Manager.
- **Security Headers:** Protection against XSS, clickjacking, and more.
- **Network Isolation:** Private subnets for application and database.
- **IAM Roles:** Least privilege access control.
===

## Monitoring & Observability

- **Application Metrics:** Response times, error rates, throughput
- **Infrastructure Metrics:** CPU, memory, network utilization
- **Auto Scaling:** Automatic response to traffic patterns
- **Alerting:** Email notifications via SNS Topic for critical events
- **Health Checks:** Multi-level health monitoring
- **Logs:** ALB access logs and VPC flow logs stored to S3
===

## Key Features

- **Responsive Design:** A mobile-friendly interface
- **Order Management:** Complete order processing workflow
- **Email Notifications:** Includes automated order confirmations
- **High Availability:** 99.9% uptime architecture
- **Auto Scaling:** Traffic spikes are automatically handled
===

## Performance

- **Auto Scaling:** 1-10 containers based on demand
- **Resource Allocation:** 0.5 vCPU, 1GB RAM per container were chosen to meet and handle expected traffic 
- **Load Balancing:** Distributed traffic across multiple containers
- **Performance:** Optimized resource allocation and auto-scaling
===

## Author

**Ryan** - [LinkedIn](https://linkedin.com/in/ryan-bongwa-535073163) | [GitHub](https://github.com/ryannb21)

---

*Thank you for visiting!*