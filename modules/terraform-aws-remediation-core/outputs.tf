output "remediation_lambda_name" {
  value = aws_lambda_function.remediation.function_name
}

output "quarantine_sg_id" {
  value = aws_security_group.quarantine.id
}
