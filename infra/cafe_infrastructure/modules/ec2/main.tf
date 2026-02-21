resource "aws_instance" "cafe_db_dedicated_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data = (file("${path.module}/ec2_db_user_data.sh"))
  iam_instance_profile = var.iam_instance_profile
  monitoring = true
  root_block_device {
    encrypted = true
    volume_type = "gp3"
    volume_size = 10
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 2
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
      instance_interruption_behavior = "terminate"
      max_price = var.spot_max_price
    }
  }

  tags = merge(var.common_tags, {
    Name = var.instance_name
  })
}