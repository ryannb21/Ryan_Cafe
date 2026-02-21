data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/build/lambda_email_sender.zip"
}

resource "aws_lambda_function" "email_sender" {
  function_name = var.lambda_function_name
  role          = var.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout      = var.timeout_seconds
  memory_size  = var.memory_mb

  environment {
    variables = {
      SES_REGION = var.ses_region
      FROM_EMAIL = var.from_email
      REPLY_TO   = var.reply_to
      APP_NAME   = var.app_name
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.order_events_queue_arn
  function_name    = aws_lambda_function.email_sender.arn

  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.max_batching_window_seconds
  enabled                            = true

  # Enables partial batch success handling (works with our Python return payload)
  function_response_types = ["ReportBatchItemFailures"]
}
