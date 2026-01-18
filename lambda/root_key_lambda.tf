resource "aws_iam_role" "root_key_fix_lambda_role" {
  name = "root-key-fix-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "root_key_lambda_basic" {
  role       = aws_iam_role.root_key_fix_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "root_key_fix_policy" {
  name = "root-key-fix-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListAccessKeys",
          "iam:DeleteAccessKey"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "root_key_fix_attach" {
  role       = aws_iam_role.root_key_fix_lambda_role.name
  policy_arn = aws_iam_policy.root_key_fix_policy.arn
}

resource "aws_lambda_function" "root_key_fix" {
  function_name = "root-key-fix"
  description   = "Deletes any root access key immediately and sends SNS alert"
  filename      = "lambda/root_key_fix.zip"
  handler       = "root_key_fix.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.root_key_fix_lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.security_alerts.arn
    }
  }

  source_code_hash = filebase64sha256("lambda/root_key_fix.zip")
}

