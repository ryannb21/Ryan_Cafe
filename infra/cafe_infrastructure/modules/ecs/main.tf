resource "aws_ecs_cluster" "cafe_ecs_cluster" {
  name = "cafe-ecs-cluster"
}

#Configuring a CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "cafe_ecs_log_group" {
  name = "/aws/ecs/ryan-cafe"
  retention_in_days = 14
}

#Configuring the Task Definition
resource "aws_ecs_task_definition" "cafe_ecs_task_definition" {
  family = "ryan-cafe"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = var.ecs_task_role_arn
  task_role_arn = var.ecs_task_role_arn

  container_definitions = jsonencode([
      {
            name = "ryan-cafe"
            image = "${var.cafe_ecr_repo_url}:latest"
            essential = true
            portMappings = [
                  { containerPort = 5000, protocol = "tcp" }
            ]
            environment = [
              {name = "AWS_REGION", value = var.aws_region},
              {name = "FLASK_CAFE_SECRET_NAME", value = var.flask_secret_name},
              {name = "EMAIL_SECRET_NAME", value = var.email_secret_name},
              {name = "DB_SECRET_NAME", value = var.db_secret_name},
            ]
            logConfiguration = {
                  logDriver = "awslogs"
                  options = {
                        awslogs-group = aws_cloudwatch_log_group.cafe_ecs_log_group.name
                        awslogs-region = var.aws_region
                        awslogs-stream-prefix = "ecs"
                  }
            }
      }
  ])
}

#Configuring the Fragate Service
resource "aws_ecs_service" "cafe_ecs_fargate_service" {
  name = "ryan-cafe-ecs-service"
  cluster = aws_ecs_cluster.cafe_ecs_cluster.id
  task_definition = aws_ecs_task_definition.cafe_ecs_task_definition.arn
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets = [var.subnet_ids]
    security_groups = [var.security_group_ids]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = "ryan-cafe"
    container_port = 5000
  }
}

#Defining the scalable target
resource "aws_appautoscaling_target" "cafe_fargate_scaling_target" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.cafe_ecs_cluster.name}/${aws_ecs_service.cafe_ecs_fargate_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = 1
  max_capacity = 5
}

#Attaching a target tracking policy to the scalable target
resource "aws_appautoscaling_policy" "cafe_fargate_scaling_policy" {
  name = "cafe_fargate_scaling_policy"
  service_namespace = aws_appautoscaling_target.cafe_fargate_scaling_target.service_namespace
  resource_id = aws_appautoscaling_target.cafe_fargate_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.cafe_fargate_scaling_target.scalable_dimension
  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50.0
    scale_in_cooldown = 300
    scale_out_cooldown = 300
  }
}