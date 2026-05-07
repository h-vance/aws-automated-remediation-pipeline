# Notification Module - Alerts and Audit Trails

resource "aws_sns_topic" "alerts" {
  name = "remediation-alerts-topic"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "SNS:Publish"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

output "alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
