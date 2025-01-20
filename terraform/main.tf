# Provider configuration
# provider "aws" {
#   assume_role {
#     role_arn = "arn:aws:iam::${var.crawler_aws_account_id}:role/minttown-pf-oidc-terraform-cloud-role"
#   }
# }

# provider "aws" { 
#   alias   = "sandbox_aws_account"
#   assume_role {
#     role_arn = "arn:aws:iam::${var.sandbox_aws_account_id}:role/minttown-pf-oidc-terraform-cloud-role"
#   }
# }

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
}

# resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
#   bucket   = aws_s3_bucket.data_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# SNS Topic in Account Crawler
resource "aws_sns_topic" "notification_topic" {
  name     = "cross-account-notification"
}

# Lambda Function A (Account Crawler)
resource "aws_lambda_function" "crawler_function" {
  filename      = "crawler_function.zip"
  function_name = "lambda_crawler_function"
  role          = aws_iam_role.crawler_function_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notification_topic.arn
      S3_BUCKET     = aws_s3_bucket.data_bucket.id
      FREECASH_SESSION_ID = var.freecash_session_id
    }
  }
}

# Lambda Updated (Account Sandbox)
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

resource "aws_iam_role" "crawler_function_role" {
  name     = "crawler_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda A
resource "aws_iam_role_policy" "crawler_function_policy" {
  role     = aws_iam_role.crawler_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = ["${aws_s3_bucket.data_bucket.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [aws_sns_topic.notification_topic.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Iam Role for Updated Function
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

resource "aws_s3_bucket_policy" "cross_crawler_aws_account_access" {
  bucket   = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.organization_id}:root"
          ]
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = ["${aws_s3_bucket.data_bucket.arn}/*"]
      }
    ]
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn      = aws_sns_topic.notification_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaA"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.crawler_function_role.arn
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.notification_topic.arn
      }
    ]
  })
}

# Lambda permissions for SNS to invoke Lambda B and C
# resource "aws_lambda_permission" "allow_sns_b" {
#   statement_id  = "AllowSNSInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.updated_function.function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.notification_topic.arn
# }

# SNS Topic Subscriptions

# resource "aws_sns_topic_subscription" "updated_function" {
#   topic_arn = aws_sns_topic.notification_topic.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.updated_function.arn
# }

