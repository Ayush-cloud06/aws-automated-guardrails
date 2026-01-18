resource "aws_iam_role" "sg_ssh_fix_lambda_role" {
  name = "sg-ssh-fix-lambda-role"

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

resource "aws_iam_role_policy_attachment" "sg_ssh_lambda_basic" {
  role       = aws_iam_role.sg_ssh_fix_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "sg_ssh_fix_policy" {
  name = "sg-ssh-fix-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:RevokeSecurityGroupIngress"
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

resource "aws_iam_role_policy_attachment" "sg_ssh_fix_attach" {
  role       = aws_iam_role.sg_ssh_fix_lambda_role.name
  policy_arn = aws_iam_policy.sg_ssh_fix_policy.arn
}


resource "aws_lambda_function" "sg_ssh_fix" {
  function_name = "sg-ssh-fix"
  description   = "Automatically revokes open SSH (22) from 0.0.0.0/0"
  filename      = "lambda/sg_ssh_fix.zip"
  handler       = "sg_ssh_fix.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.sg_ssh_fix_lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.security_alerts.arn
    }
  }

  source_code_hash = filebase64sha256("lambda/sg_ssh_fix.zip")
}
