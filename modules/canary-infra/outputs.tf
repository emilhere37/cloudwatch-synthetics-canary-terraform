#modules/canary-infra/outputs.tf

output "reports_bucket" {
    description = "The name of the S3 bucket for canary artifacts"
    value       = aws_s3_bucket.canary_artifacts.id
}

output "role_arn" {
    description ="The ARN of the IAM role for the canary"
    value       =aws_iam_role.canary_role.arn
}

output "security_group"{
    description = "The security group ID for the canary"
    value       =aws_security_group.canary_sg.id
}