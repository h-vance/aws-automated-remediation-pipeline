# Detection Module - EventBridge Rules to trigger remediation

# Dead Letter Queue for failed EventBridge deliveries
resource "aws_sqs_queue" "eventbridge_dlq" {
  name                      = "remediation-detection-dlq"
  message_retention_seconds = 1209600 # 14 days
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue_policy" "dlq_policy" {
  queue_url = aws_sqs_queue.eventbridge_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sqs:SendMessage"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Resource = aws_sqs_queue.eventbridge_dlq.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.high_cpu_trigger.arn
          }
        }
      }
    ]
  })
}

# IAM Role for EventBridge to start Step Functions
resource "aws_iam_role" "eventbridge" {
  name = "remediation-detection-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "eventbridge" {
  name        = "remediation-detection-policy"
  description = "Allows EventBridge to start Step Functions state machines"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "states:StartExecution"
        Effect = "Allow"
        Resource = [
          var.state_machine_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  role       = aws_iam_role.eventbridge.name
  policy_arn = aws_iam_policy.eventbridge.arn
}

# Scenario: EC2 High CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "ec2-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  # Note: In a real scenario, this would target specific instances or an ASG
  dimensions = {
    InstanceId = var.test_instance_id
  }
}

# EventBridge Rule: Trigger on CloudWatch Alarm change to ALARM
resource "aws_cloudwatch_event_rule" "high_cpu_trigger" {
  name        = "trigger-remediation-on-high-cpu"
  description = "Triggers remediation state machine when high CPU alarm is raised"

  event_pattern = jsonencode({
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {
      "alarmName": [aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name],
      "state": {
        "value": ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "step_function" {
  rule      = aws_cloudwatch_event_rule.high_cpu_trigger.name
  target_id = "TriggerStepFunction"
  arn       = var.state_machine_arn
  role_arn  = aws_iam_role.eventbridge.arn

  dead_letter_config {
    arn = aws_sqs_queue.eventbridge_dlq.arn
  }

  # Map the instance ID from the alarm/context to the Step Function input
  input_transformer {
    input_paths = {
      instance_id = "$.detail.configuration.metrics[0].metricStat.metric.dimensions.InstanceId"
    }
    input_template = <<EOF
{
  "instance_id": <instance_id>,
  "source": "CloudWatch Alarm",
  "reason": "High CPU Utilization"
}
EOF
  }
}
