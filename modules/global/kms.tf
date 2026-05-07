# KMS Encryption Key for Remediation Data
resource "aws_kms_key" "remediation" {
  description             = "Encryption key for remediation logs, state, and notifications"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*" # Scoped by IAM policies
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.us-east-1.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "remediation" {
  name          = "alias/remediation-key"
  target_key_id = aws_kms_key.remediation.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.remediation.arn
}
