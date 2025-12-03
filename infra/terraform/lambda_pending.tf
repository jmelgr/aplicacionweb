resource "aws_lambda_function" "lambda_pending" {
  function_name = "lambda-pending-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename         = "../lambdas/lambda_pending/lambda_pending.zip"
  source_code_hash = filebase64sha256("../lambdas/lambda_pending/lambda_pending.zip")

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  timeout = 30
}

resource "aws_lambda_event_source_mapping" "pending_sqs_trigger" {
  event_source_arn = aws_sqs_queue.file_events_queue.arn
  function_name    = aws_lambda_function.lambda_pending.arn

  batch_size = 5
  enabled    = true
}
