# AWS OIDC and GitHub Actions IAM Configuration
# This module sets up the trust relationship between GitHub Actions and AWS.

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:h-vance/aws-automated-remediation-pipeline:*"
          }
        }
      }
    ]
  })
}

# Scoped Policy for Terraform Operations
resource "aws_iam_policy" "terraform_permissions" {
  name        = "terraform-remediation-pipeline-policy"
  description = "Scoped permissions for the automated remediation pipeline deployment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # S3 State Access
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "*" # Scoped to state bucket in production
      },
      {
        # DynamoDB Lock Access
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Effect   = "Allow"
        Resource = "*" # Scoped to lock table in production
      },
      {
        # Compute, Orchestration, and Networking
        Action = [
          "lambda:*",
          "states:*",
          "events:*",
          "sns:*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          "ec2:DescribeInstances",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        # IAM Management (Required for Terraform to create roles)
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_permissions.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
