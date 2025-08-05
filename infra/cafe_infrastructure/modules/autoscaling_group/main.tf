#Creating the Launch Template
resource "aws_launch_template" "cafe_ASG_LaunchTemplate" {
  name = "${var.asg_name_prefix}-ASG_LaunchTemplate"
  image_id = var.ami_id
  instance_type = var.asg_instance_type
  user_data = base64encode(file("${path.module}/user_data.sh"))
  network_interfaces {
    security_groups = var.asg_security_group_ids
  }
  iam_instance_profile {
    name = var.instance_profile_name
  }
  lifecycle {
    create_before_destroy = true
  }
}


#Creating the Auto Scaling Group
resource "aws_autoscaling_group" "cafe_ASG" {
  name = "${var.asg_name_prefix}-asg"
  launch_template {
    id = aws_launch_template.cafe_ASG_LaunchTemplate.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids
  target_group_arns = [var.target_group_arn]

  desired_capacity = var.asg_desired_capacity
  min_size = var.asg_min_size
  max_size = var.asg_max_size

  health_check_type = "ELB"
  health_check_grace_period = 300
  force_delete = true
  

  tag {
    key = "Name"
    value = "${var.asg_name_prefix}-ASG_LaunchTemplate"
    propagate_at_launch = true 
}
}


#Creating Scaling Policies
#Creating the Scale-Up Policy
resource "aws_autoscaling_policy" "cafe_asg_scale_up" {
  name = "${var.asg_name_prefix}-scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.cafe_ASG.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.asg_up_scaling_adjustment
  cooldown = 360
}

#Creating the Scale-Down Policy
resource "aws_autoscaling_policy" "cafe_asg_scale_down" {
  name = "${var.asg_name_prefix}-scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.cafe_ASG.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.asg_down_scaling_adjustment
  cooldown = 240
}


#Creating the ASG Notifications
resource "aws_autoscaling_notification" "cafe_asg_notifications" {
  group_names = [aws_autoscaling_group.cafe_ASG.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = var.sns_topic_arn
}