resource "aws_cloudwatch_event_rule" "root_key_created" {
  name        = "root-access-key-created"
  description = "Detect creation of access keys for root user"

  event_pattern = jsonencode({
    source        = ["aws.iam"]
    "detail-type" = ["AWS API Call Via CloudTrail"],
    detail = {
      eventSource = ["iam.amazonaws.com"],
      eventName   = ["CreateAccessKey"],
      userIdentity = {
        type = ["Root"]
      }
    }
  })
}

resource "aws_lambda_permission" "allow_eventbridge_root_key" {
  statement_id  = "AllowExecutionFromEventBridgeRootKey"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.root_key_fix.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.root_key_created.arn
}

resource "aws_cloudwatch_event_target" "root_key_target" {
  rule      = aws_cloudwatch_event_rule.root_key_created.name
  target_id = "RootKeyFixLambda"
  arn       = aws_lambda_function.root_key_fix.arn
}
