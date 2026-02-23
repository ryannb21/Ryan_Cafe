#Creating the cluster
resource "aws_ecs_cluster" "cafe_ecs_cluster" {
  name = var.ecs_cluster_name
}

#CloudWatch Logs for ECS
resource "aws_cloudwatch_log_group" "cafe_ecs_log_group" {
  name = var.ecs_log_group_name
  retention_in_days = 14
}

# Configuring Service Discovery for Orders 
resource "aws_service_discovery_private_dns_namespace" "cafe_ns" {
  name = var.service_discovery_namespace_name
  description = "Private namespace for cafe services"
  vpc = var.vpc_id
}

resource "aws_service_discovery_service" "orders_sd" {
  name = "orders"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cafe_ns.id

    dns_records {
      ttl = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# CONFIGURING THE WEB_FRONTEND TASK DEFINITION
resource "aws_ecs_task_definition" "web_task" {
  family = "${var.family}-web"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = var.web_cpu
  memory = var.web_memory
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.ecs_web_task_role_arn

  container_definitions = jsonencode([
    {
      name = "web-frontend"
      image = var.web_image
      essential = true

      portMappings = [
        { containerPort = 5000, protocol = "tcp"}
      ]

      environment = [
        {name = "AWS_REGION", value = var.aws_region},
        {name = "FLASK_CAFE_SECRET_NAME", value = var.flask_secret_name},
        {name = "ORDERS_BASE_URL", value = "http://orders.${var.service_discovery_namespace_name}:5001"},
        {name = "ORDERS_TIMEOUT_SEC", value = "5.0"}
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.cafe_ecs_log_group.name
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "web"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "web_service" {
  name = "${var.family}-web-svc"
  cluster = aws_ecs_cluster.cafe_ecs_cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn 
  desired_count = var.web_desired_count
  launch_type = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets = var.app_subnet_ids
    security_groups = var.web_security_group_ids
    assign_public_ip = false 
  }

  load_balancer {
    target_group_arn = var.web_target_group_arn
    container_name = "web-frontend"
    container_port = 5000
  }
}


#CONFIGURING THE ORDER SERVICE TAKS DEFINITION
resource "aws_ecs_task_definition" "orders_task" {
  family = "${var.family}-orders"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = var.orders_cpu
  memory = var.orders_memory
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn = var.ecs_orders_task_role_arn

  container_definitions = jsonencode([
    {
      name = "orders-service"
      image = var.orders_image
      essential = true

      portMappings = [
        { containerPort = 5001, protocol = "tcp"}
      ]

      environment = [
        {name = "AWS_REGION", value = var.aws_region},
        {name = "DB_SECRET_NAME", value = var.db_secret_name},
        {name = "ORDERS_EVENTS_QUEUE_URL", value = var.order_events_queue_url}
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.cafe_ecs_log_group.name
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "orders"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "orders_service" {
  name = "${var.family}-orders-svc"
  cluster = aws_ecs_cluster.cafe_ecs_cluster.id
  task_definition = aws_ecs_task_definition.orders_task.arn 
  desired_count = var.orders_desired_count
  launch_type = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets = var.app_subnet_ids
    security_groups = var.orders_security_group_ids
    assign_public_ip = false 
  }

  service_registries {
    registry_arn = aws_service_discovery_service.orders_sd.arn
  }
}


#CONFIGURING THE AUTO SCALING POLICING
#web scaling target and policy
resource "aws_appautoscaling_target" "web_scaling_target" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.cafe_ecs_cluster.name}/${aws_ecs_service.web_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity = var.web_min_capacity
  max_capacity = var.web_max_capacity
}

resource "aws_appautoscaling_policy" "web_scaling_policy" {
  name = "${var.family}-web-scaling"
  service_namespace = aws_appautoscaling_target.web_scaling_target.service_namespace
  resource_id = aws_appautoscaling_target.web_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.web_scaling_target.scalable_dimension
  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.web_cpu_target
    scale_in_cooldown = 300
    scale_out_cooldown = 300
  }
}

#app scaling target and policy
resource "aws_appautoscaling_target" "orders_scaling_target" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.cafe_ecs_cluster.name}/${aws_ecs_service.orders_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity = var.web_min_capacity
  max_capacity = var.web_max_capacity
}

resource "aws_appautoscaling_policy" "orders_scaling_policy" {
  name = "${var.family}-orders-scaling"
  service_namespace = aws_appautoscaling_target.orders_scaling_target.service_namespace
  resource_id = aws_appautoscaling_target.orders_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.orders_scaling_target.scalable_dimension
  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.web_cpu_target
    scale_in_cooldown = 300
    scale_out_cooldown = 300
  }
}