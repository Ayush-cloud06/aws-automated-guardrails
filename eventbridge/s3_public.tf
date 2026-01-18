resource "aws_cloudwatch_event_rule" "s3_public_noncompliant" {
  name = "s3-public-bucket-detected"

  event_pattern = jsonencode({
    source        = ["aws.config"]
    "detail-type" = ["Config Rules Compliance Change"]
    detail = {
      configRuleName = ["s3-bucket-public-read-prohibited"]
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge_s3" {
  statement_id  = "AllowExecutionFromEventBridgeS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_public_fix.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_public_noncompliant.arn
}

# Attach rule to Lambda
resource "aws_cloudwatch_event_target" "s3_public_target" {
  rule      = aws_cloudwatch_event_rule.s3_public_noncompliant.name
  target_id = "S3PublicFixLambda"
  arn       = aws_lambda_function.s3_public_fix.arn
}
