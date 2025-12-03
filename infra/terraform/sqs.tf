resource "aws_sqs_queue" "file_events_queue" {
  name                       = "file-events-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
}

resource "aws_sqs_queue_policy" "allow_ec2_send" {
  queue_url = aws_sqs_queue.file_events_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2SendMessage"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.file_events_queue.arn
      }
    ]
  })
}
