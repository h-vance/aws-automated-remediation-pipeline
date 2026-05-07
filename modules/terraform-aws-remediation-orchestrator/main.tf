# Orchestration Module - Step Functions State Machine

resource "aws_iam_role" "step_functions" {
  name = "remediation-orchestrator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "step_functions" {
  name        = "remediation-orchestrator-policy"
  description = "Allows Step Functions to invoke Lambda and publish to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect = "Allow"
        Resource = [
          var.remediation_lambda_arn
        ]
      },
      {
        Action = "sns:Publish"
        Effect = "Allow"
        Resource = [
          var.alerts_topic_arn
        ]
      },
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions" {
  role       = aws_iam_role.step_functions.name
  policy_arn = aws_iam_policy.step_functions.arn
}

resource "aws_sfn_state_machine" "remediation" {
  name     = "remediation-orchestrator"
  role_arn = aws_iam_role.step_functions.arn

  tracing_configuration {
    enabled = true
  }

  definition = jsonencode({
    Comment = "Orchestration for Automated Incident Remediation"
    StartAt = "AnalyzeIncident"
    States = {
      AnalyzeIncident = {
        Type = "Pass"
        Result = {
          "can_remediate" = true
        }
        ResultPath = "$.analysis"
        Next       = "CheckRemediationPossible"
      }
      CheckRemediationPossible = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.analysis.can_remediate"
            BooleanEquals = true
            Next          = "ExecuteRemediation"
          }
        ]
        Default = "NotifyFailure"
      }
      ExecuteRemediation = {
        Type = "Task"
        Resource = var.remediation_lambda_arn
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2.0
          }
        ]
        Next = "NotifySuccess"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "NotifyFailure"
          }
        ]
      }
      NotifySuccess = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.alerts_topic_arn
          Message = {
            "status"      = "SUCCESS"
            "instance_id" = "$.instance_id"
            "action"      = "EC2 Isolation"
          }
        }
        End = true
      }
      NotifyFailure = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.alerts_topic_arn
          Message = {
            "status"      = "FAILED"
            "instance_id" = "$.instance_id"
            "reason"      = "Remediation logic failed or was not possible"
          }
        }
        End = true
      }
    }
  })
}
