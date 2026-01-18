resource "aws_cloudwatch_event_rule" "sg_ssh_noncompliant" {
  name        = "sg-open-ssh-detected"
  description = "Detect security groups that allow SSH from 0.0.0.0/0"

  event_pattern = jsonencode({
    source        = ["aws.config"],
    "detail-type" = ["Config Rules Compliance Change"],
    detail = {
      configRuleName = ["restricted-ssh"],
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_lambda_permission" "allow_eventbridge_sg_ssh" {
  statement_id  = "AllowExecutionFromEventBridgeSGSSH"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sg_ssh_fix.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sg_ssh_noncompliant.arn
}

resource "aws_cloudwatch_event_target" "sg_ssh_target" {
  rule      = aws_cloudwatch_event_rule.sg_ssh_noncompliant.name
  target_id = "SGSSHFIX"
  arn       = aws_lambda_function.sg_ssh_fix.arn
}
