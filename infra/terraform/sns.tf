resource "aws_sns_topic" "file_topic" {
  name = "file-events-topic"
}

resource "aws_sns_topic_subscription" "pending_subscription" {
  topic_arn = aws_sns_topic.file_topic.arn
  protocol  = "lambda"

  endpoint = "arn:aws:lambda:us-east-1:518474287858:function:lambda-pending-processor"
}

resource "aws_sns_topic_subscription" "cleanup_subscription" {
  topic_arn = aws_sns_topic.file_topic.arn
  protocol  = "lambda"

  endpoint = "arn:aws:lambda:us-east-1:518474287858:function:lambda-cleanup-processor"
}

resource "aws_lambda_permission" "allow_sns_pending" {
  statement_id  = "AllowExecutionFromSNSPending"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-pending-processor"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.file_topic.arn
}

resource "aws_lambda_permission" "allow_sns_cleanup" {
  statement_id  = "AllowExecutionFromSNSCleanup"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-cleanup-processor"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.file_topic.arn
}
