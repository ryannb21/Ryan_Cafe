resource "aws_instance" "cafe_db_dedicated_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data = base64encode(file("${path.module}/ec2_db_user_data.sh"))
  iam_instance_profile = var.iam_instance_profile
  monitoring = true
  root_block_device {
    encrypted = true
    volume_type = "gp3"
    volume_size = 10
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "persistent"
      instance_interruption_behavior = "terminate"
      max_price = "0.05"
    }
  }

  tags = {
    "Name" = "db_dedicated_ec2"
    "Project" = "Cafe_App"
  }
}