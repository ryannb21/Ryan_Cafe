data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cafe_ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

#Creating the EC2 Role for Session Manager
resource "aws_iam_role" "cafe_db_ec2_ssm_role" {
  name = var.db_ec2_ssm_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_ec2_assume_role.json
}

#Attaching the SSM Managed Policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "cafe_ssm_managed_policy_attachment" {
  role = aws_iam_role.cafe_db_ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#Creating the dedicated db EC2 instance profile
resource "aws_iam_instance_profile" "db_ec2_ssm_profile" {
  name = var.db_ec2_ssm_profile_name
  role = aws_iam_role.cafe_db_ec2_ssm_role.name
}

data "aws_iam_policy_document" "cafe_ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

#Creating the ECS Task Role
resource "aws_iam_role" "cafe_ecs_task_role" {
  name = var.aws_ecs_task_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_ecs_task_assume_role.json
}

#Attaching the AWS Managed ECS executiomn role policy
resource "aws_iam_role_policy_attachment" "cafe_ecs_task_policy_attach" {
  role = aws_iam_role.cafe_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Creating the Secrets Manager Policy Document
data "aws_iam_policy_document" "cafe_ecs_read_secret" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      ]
    resources = var.secret_arns
    effect = "Allow"
  }
}

#Attaching the Secrets Manager Policy to the ECS Task Role
resource "aws_iam_role_policy" "cafe_ecs_read_secrets_inline" {
  name = "cafe_ecs_read_secrets_policy"
  role = aws_iam_role.cafe_ecs_task_role.name
  policy = data.aws_iam_policy_document.cafe_ecs_read_secret.json
}