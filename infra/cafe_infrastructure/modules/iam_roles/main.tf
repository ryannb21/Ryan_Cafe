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

#Creating the Secrets Manager Policy Document
data "aws_iam_policy_document" "cafe_read_secret" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      ]
    resources = var.secret_arns
    effect = "Allow"
  }
}


#Creating the Session Manager Policy Document
data "aws_iam_policy_document" "cafe_ssm_core_policy" {
  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

#Creating the EC2 Role for Secrets Manager and Session Manager
resource "aws_iam_role" "cafe_combined_role" {
  name = var.aws_iam_role_name_combined
  assume_role_policy = data.aws_iam_policy_document.cafe_ec2_assume_role.json
}

resource "aws_iam_role_policy" "cafe_read_secret_policy" {
  name = "cafe_read_secret_policy"
  role = aws_iam_role.cafe_combined_role.id
  policy = data.aws_iam_policy_document.cafe_read_secret.json
}

resource "aws_iam_role_policy" "cafe_ssm_core_policy" {
  name = "cafe_ssm_core_policy"
  role = aws_iam_role.cafe_combined_role.id
  policy = data.aws_iam_policy_document.cafe_ssm_core_policy.json
}

resource "aws_iam_instance_profile" "cafe_combined_profile" {
  name = var.instance_profile_name_combined
  role = aws_iam_role.cafe_combined_role.name
}