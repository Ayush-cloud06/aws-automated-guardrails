resource "aws_cloudwatch_event_rule" "root_key_created" {
  name        = "root-access-key-crerated"
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
