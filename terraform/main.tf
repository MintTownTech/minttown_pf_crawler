# Provider configuration
provider "aws" {
  alias = "crawler_aws_account"
  assume_role {
    role_arn = "arn:aws:iam::${var.crawler_aws_account_id}:role/minttown-pf-oidc-terraform-cloud-role"
  }
}

provider "aws" { 
  alias = "sandbox_aws_account"
  assume_role {
    role_arn = "arn:aws:iam::${var.sandbox_aws_account_id}:role/minttown-pf-oidc-terraform-cloud-role"
  }
}


resource "aws_s3_bucket" "data_bucket" {
  provider = aws.crawler_aws_account
  bucket   = "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  provider = aws.crawler_aws_account
  bucket   = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SNS Topic in Account Crawler
resource "aws_sns_topic" "notification_topic" {
  provider = aws.crawler_aws_account
  name     = "cross-account-notification"
}

# Lambda Function A (Account Crawler)
resource "aws_lambda_function" "crawler_function" {
  provider      = aws.crawler_aws_account
  filename      = "crawler_function.zip"
  function_name = "lambda_crawler_function"
  role          = aws_iam_role.lambda_a_role.arn
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
resource "aws_lambda_function" "updated_function" {
  provider      = aws.sandbox_aws_account
  filename      = "updated_function.zip"
  function_name = "lambda_updated_function"
  role          = aws_iam_role.lambda_b_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      SOURCE_BUCKET = aws_s3_bucket.data_bucket.id
    }
  }
}

resource "aws_iam_role" "lambda_a_role" {
  provider = aws.crawler_aws_account
  name     = "lambda_a_role"

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
resource "aws_iam_role_policy" "lambda_a_policy" {
  provider = aws.crawler_aws_account
  role     = aws_iam_role.lambda_a_role.id

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

# IAM Roles for Lambda B and C
resource "aws_iam_role" "lambda_b_role" {
  provider = aws.sandbox_aws_account
  name     = "lambda_b_role"

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

resource "aws_s3_bucket_policy" "cross_crawler_aws_accountccess" {
  provider = aws.crawler_aws_account
  bucket   = aws_s3_bucket.data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.lambda_b_role.arn,
            aws_iam_role.lambda_c_role.arn
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
  provider = aws.crawler_aws_account
  arn      = aws_sns_topic.notification_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaA"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_a_role.arn
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.notification_topic.arn
      }
    ]
  })
}

# Lambda permissions for SNS to invoke Lambda B and C
resource "aws_lambda_permission" "allow_sns_b" {
  provider      = aws.sandbox_aws_account
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updated_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.notification_topic.arn
}

# resource "aws_lambda_permission" "allow_sns_c" {
#   provider      = aws.account_c
#   statement_id  = "AllowSNSInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.function_c.function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.notification_topic.arn
# }

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "lambda_b" {
  provider  = aws.crawler_aws_account
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.updated_function.arn
}

resource "aws_sns_topic_subscription" "lambda_c" {
  provider  = aws.crawler_aws_account
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.function_c.arn
}
