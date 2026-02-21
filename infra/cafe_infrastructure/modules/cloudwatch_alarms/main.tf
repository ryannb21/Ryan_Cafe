#CONFIGURING THE CPU & MEMORY ALARAMS FOR ECS
#WEB CPU + MEMORY ALARMS
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name = "Cafe-Web-High-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_cpu_threshold
  alarm_description = "Web service CPU >= ${var.cw_high_cpu_threshold}%"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.web_service_name 
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "web_mem_high" {
  alarm_name = "Cafe-Web-High-Memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_mem_threshold
  alarm_description = "Web service Memory >= ${var.cw_high_mem_threshold}%"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.web_service_name 
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#ORDERS CPU + MEMORY ALARMS
resource "aws_cloudwatch_metric_alarm" "orders_cpu_high" {
  alarm_name = "Cafe-Orders-High-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_cpu_threshold
  alarm_description = "Orders service CPU >= ${var.cw_high_cpu_threshold}%"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.orders_service_name 
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "orders_mem_high" {
  alarm_name = "Cafe-Orders-High-Memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cw_high_eval_periods
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = var.cw_high_cpu_eval_duration
  statistic = "Average"
  threshold = var.cw_high_mem_threshold
  alarm_description = "Orders service Memory >= ${var.cw_high_mem_threshold}%"
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.orders_service_name 
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#CONFIGURING THE ALB TARGET 5XX ALARM FOR WEB RELIABILITY MONITORING
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name = "Cafe-ALB-Target-5XX"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "HTTPCode_Target_5XX_Count"
  namespace = "AWS/ApplicationELB"
  period = 60
  statistic = "Sum"
  threshold = var.alb_target_5xx_threshold
  alarm_description = "ALB target 5XX errors > ${var.alb_target_5xx_threshold}"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup = var.target_group_arn_suffix
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#CONFIGURING LAMBDA ERRORS ALARM FOR EMAIL SENDER
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name = "Cafe-Lambda-Email-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = 60
  statistic = "Sum"
  threshold = var.lambda_errors_threshold
  alarm_description = "Lambda email sender errors > ${var.lambda_errors_threshold} in 1 minute"
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#CONFIGURING SQS QUEUE DEPTH ALARM FOR BACKLOG MONITIORING
resource "aws_cloudwatch_metric_alarm" "sqs_backlog" {
  alarm_name = "Cafe-SQS-OrderEvents-Backlog"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = 60
  statistic = "Average"
  threshold = var.sqs_backlog_threshold
  alarm_description = "Order events queue backlog above ${var.sqs_backlog_threshold}"
  dimensions = {
    QueueName = var.order_events_queue_name
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#CONFIGURING SQS DLQ ALARM
resource "aws_cloudwatch_metric_alarm" "sqs_dlq_visible" {
  alarm_name = "Cafe-SQS-DLQ-HasMessages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace = "AWS/SQS"
  period = 60
  statistic = "Average"
  threshold = var.dlq_visible_threshold
  alarm_description = "DLQ has messages (>= ${var.dlq_visible_threshold}"
  dimensions = {
    QueueName = var.order_events_dlq_name
  }
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

#CONFIGURING A CLOUDWATCH DASHBOARD TO VIEW ALL THESE ABOVE ALARMS
resource "aws_cloudwatch_dashboard" "cafe_ops" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0, y = 0, width = 12, height = 6,
        properties = {
          title = "ECS Web CPU/Memory",
          region = var.aws_region,
          annotations = {},
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.web_service_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ],
          period = 60,
          stat = "Average"
        }
      },
      {
        type = "metric",
        x = 12, y = 0, width = 12, height = 6,
        properties = {
          title = "ECS Orders CPU/Memory",
          region = var.aws_region,
          annotations = {},
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.orders_service_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ],
          period = 60,
          stat = "Average"
        }
      },
      {
        type = "metric",
        x = 0, y = 6, width = 12, height = 6,
        properties = {
          title = "ALB Target 5XX + Response Time",
          region = var.aws_region,
          annotations = {},
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, {"stat" : "Sum"}],
            [".", "TargetResponseTime", ".", ".", ".", ".", {"stat": "Average"}]
          ],
          period = 60,
        }
      },
      {
        type = "metric",
        x = 12, y = 6, width = 12, height = 6,
        properties = {
          title = "SQS Queue + DLQ Visible Messages",
          region = var.aws_region,
          annotations = {},
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.order_events_queue_name, {"stat" : "Average"}],
            [".", "ApproximateNumberOfMessagesVisible", "QueueName", var.order_events_dlq_name, {"stat": "Average"}]
          ],
          period = 60,
        }
      },
      {
        type = "metric",
        x = 0, y = 12, width = 12, height = 6,
        properties = {
          title = "Lambda Email Sender (Invocations/Errors)",
          region = var.aws_region,
          annotations = {},
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name, {"stat" : "Sum"}],
            [".", "Errors", ".", ".", {"stat": "Average"}]
          ],
          period = 60,
        }
      }
    ]
  })
}