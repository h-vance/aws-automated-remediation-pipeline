# Remediation Module - Infrastructure for automated fixes

# Quarantine Security Group: Denies all ingress and egress
resource "aws_security_group" "quarantine" {
  name        = "remediation-quarantine-sg"
  description = "Restricted security group for isolated instances"
  vpc_id      = var.vpc_id

  # Explicitly deny all ingress and egress
  ingress = []
  egress  = []

  tags = {
    Name    = "quarantine-sg"
    Project = "aws-automated-remediation"
  }
}

# IAM Role for Remediation Lambda
resource "aws_iam_role" "remediation_lambda" {
  name = "remediation-executor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Least-privilege policy for EC2 isolation
resource "aws_iam_policy" "remediation_policy" {
  name        = "remediation-executor-policy"
  description = "Allows Lambda to modify instance attributes for isolation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstances"
        ]
        Effect   = "Allow"
        Resource = "*" # Scoped to VPC/Region in production
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "remediation_attach" {
  role       = aws_iam_role.remediation_lambda.name
  policy_arn = aws_iam_policy.remediation_policy.arn
}

# Lambda Function: Remediation Executor
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/remediation_executor"
  output_path = "${path.module}/remediation_executor.zip"
}

resource "aws_lambda_function" "remediation" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "remediation-executor"
  role             = aws_iam_role.remediation_lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  environment {
    variables = {
      QUARANTINE_SG_ID = aws_security_group.quarantine.id
    }
  }
}

resource "aws_cloudwatch_log_group" "remediation" {
  name              = "/aws/lambda/remediation-executor"
  retention_in_days = 14
}
