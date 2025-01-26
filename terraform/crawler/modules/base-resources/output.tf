// filepath: /home/vennpham/workspaces/mint/github/minttown_pf_crawler/terraform/main.tf
output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.notification_topic.arn
}

output "lambda_function_role_arn" {
  value = aws_iam_role.crawler_function_role.arn
}

output "crawler_function_role" {
  value = aws_iam_role.crawler_function_role.arn
}
