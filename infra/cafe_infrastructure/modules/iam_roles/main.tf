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



#CREATING THE ECS ASSUME ROLE POLICY
data "aws_iam_policy_document" "cafe_ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

#Creating and Attaching the shared ECS Task Role
resource "aws_iam_role" "cafe_ecs_execution_role" {
  name = var.ecs_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cafe_ecs_execution_policy_attach" {
  role = aws_iam_role.cafe_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#Creating ECS WEB FRONTEND TASK ROLE
#This role is meant to read only the app/flask secrets needed
resource "aws_iam_role" "cafe_ecs_web_task_role" {
  name = var.ecs_web_task_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_ecs_task_assume_role.json
}

data "aws_iam_policy_document" "cafe_ecs_web_read_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.web_secret_arns
  }
}

resource "aws_iam_role_policy" "cafe_ecs_web_read_secrets_inline" {
  name = "cafe_ecs_web_read_secrets_policy"
  role = aws_iam_role.cafe_ecs_web_task_role.name
  policy = data.aws_iam_policy_document.cafe_ecs_web_read_secrets.json
}


#Creating ECS ORDER_SERVICE TASK ROLE
#This role is meant to read only the DB secrets needed and send messages to SQS (order events)
resource "aws_iam_role" "cafe_ecs_orders_task_role" {
  name = var.ecs_orders_task_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_ecs_task_assume_role.json
}

data "aws_iam_policy_document" "cafe_ecs_orders_read_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.orders_secret_arns
  }
}

data "aws_iam_policy_document" "cafe_ecs_orders_sqs_send" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.order_events_queue_arn]
  }
}

resource "aws_iam_role_policy" "cafe_ecs_orders_inline_policy" {
  name = "cafe_ecs_orders_policy"
  role = aws_iam_role.cafe_ecs_orders_task_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      jsondecode(data.aws_iam_policy_document.cafe_ecs_orders_read_secrets.json).Statement,
      jsondecode(data.aws_iam_policy_document.cafe_ecs_orders_sqs_send.json).Statement
    )
  })
}


#CREATING THE LAMBDA ROLE - EMAIL SENDER
data "aws_iam_policy_document" "cafe_lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "cafe_lambda_email_role" {
  name = var.lambda_email_role_name
  assume_role_policy = data.aws_iam_policy_document.cafe_lambda_assume_role.json
}

# CloudWatch Logs for Lambda
resource "aws_iam_role_policy_attachment" "cafe_lambda_basic_exec_attach" {
  role = aws_iam_role.cafe_lambda_email_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SQS Consume Permissions
data "aws_iam_policy_document" "cafe_lambda_sqs_consume" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [ var.order_events_queue_arn ]
  }
}

# SES Send Permissions
data "aws_iam_policy_document" "cafe_lambda_ses_send" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cafe_lambda_email_inline_policy" {
  name = "cafe_lambda_email_policy"
  role = aws_iam_role.cafe_lambda_email_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      jsondecode(data.aws_iam_policy_document.cafe_lambda_sqs_consume.json).Statement,
      jsondecode(data.aws_iam_policy_document.cafe_lambda_ses_send.json).Statement
    )
  })
}