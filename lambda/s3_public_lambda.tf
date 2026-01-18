resource "aws_iam_role" "s3_fix_lambda_role" {
  name = "s3-public-fix-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.s3_fix_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "s3_public_fix" {
  function_name = "s3-public-fix"
  filename      = "lambda/s3_public_fix.zip"
  handler       = "s3_public_fix.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.s3_fix_lambda_role.arn

  source_code_hash = filebase64sha256("lambda/s3_public_fix.zip")
}

resource "aws_iam_policy" "s3_fix_policy" {
  name = "s3-public-fix-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketAcl",
          "s3:PutBucketAcl"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_fix_attach" {
  role       = aws_iam_role.s3_fix_lambda_role.name
  policy_arn = aws_iam_policy.s3_fix_policy.arn
}

resource "aws_iam_role_policy" "s3_lambda_sns_policy" {
  name = "s3-lambda-sns-policy"
  role = aws_iam_role.s3_fix_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.security_alerts.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutBucketAcl",
          "s3:PutPublicAccessBlock"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_lambda_function" "s3_public_fix" {
  function_name = "s3-public-fix"
  filename      = "lambda/s3_public_fix.zip"
  handler       = "s3_public_fix.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.s3_fix_lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.security_alerts.arn
    }
  }

  source_code_hash = filebase64sha256("lambda/s3_public_fix.zip")
}
