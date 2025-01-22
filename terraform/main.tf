resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
}

# SNS Topic in Account Crawler
resource "aws_sns_topic" "notification_topic" {
  name     = "crawler-cross-account-notification"
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  topic {
    topic_arn = aws_sns_topic.notification_topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.default]
}

# Lambda Function A (Account Crawler)
resource "aws_lambda_function" "crawler_function" {
  function_name = "lambda_crawler_function"
  s3_bucket     = aws_s3_bucket.data_bucket.id
  s3_key        = "lambda_function.zip"
  role          = aws_iam_role.crawler_function_role.arn
  handler       = "dist/lambda_handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30  # Increase the timeout to 30 seconds

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notification_topic.arn
      S3_BUCKET     = aws_s3_bucket.data_bucket.id
      FREECASH_SESSION_ID = var.freecash_session_id
      COUNTRY = "US"
    }
  }
}

# IAM Role for Lambda Crawler
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

# Bucket Policy for Cross Account Access
resource "aws_s3_bucket_policy" "cross_crawler_aws_account_access" {
  bucket = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
            AWS = [
            "arn:aws:iam::${var.sandbox_aws_account_id}:root",
            "arn:aws:iam::${var.sandbox_aws_account_id}:role/updated_function_role"
            ]
        }
        Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectAcl"
        ]
        Resource = ["${aws_s3_bucket.data_bucket.arn}/*"]
      }
    ]
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.notification_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3BucketNotifications"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.notification_topic.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.data_bucket.arn
          }
        }
      },
      {
        Sid    = "AllowSubscribeFromSpecificAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.sandbox_aws_account_id}:root"
        }
        Action   = "SNS:Subscribe"
        Resource = aws_sns_topic.notification_topic.arn
      }
    ]
  })
}
