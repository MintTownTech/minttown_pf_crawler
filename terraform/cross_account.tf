# resource "aws_lambda_function" "updated_function" {
#   filename      = "updated_function.zip"
#   function_name = "lambda_updated_function"
#   role          = aws_iam_role.updated_function_role.arn
#   handler       = "index.handler"
#   runtime       = "nodejs20.x"
#   environment {
#     variables = {
#       SOURCE_BUCKET = aws_s3_bucket.data_bucket.id
#     }
#   }
# }
# resource "aws_iam_role" "updated_function_role" {
#   name     = "updated_function_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
# resource "aws_lambda_permission" "allow_sns_b" {
#   statement_id  = "AllowSNSInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.updated_function.function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.notification_topic.arn
# }
# resource "aws_sns_topic_subscription" "updated_function" {
#   topic_arn = aws_sns_topic.notification_topic.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.updated_function.arn
# }