resource "null_resource" "force_update" {
  triggers = {
    commit_hash = var.commit_hash
  }

  provisioner "local-exec" {
    command = "echo 'Forcing Lambda function update'"
  }
}

resource "aws_lambda_function" "updated_function" {
  function_name = "updated-crawler-function-${var.env}"
  filename        = "source-${var.commit_hash}.zip"
  role          = aws_iam_role.updated_function_role.arn
  handler       = "dist/updated_handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30  # Increase the timeout to 30 seconds
  layers        = [aws_lambda_layer_version.crawler_updated_function_layer.arn]
  publish       = true  # Force update code when resource has no changes
  environment {
    variables = {
      S3_BUCKET     = var.bucket_name
    }
  }
  depends_on = [null_resource.force_update]
}

resource "aws_lambda_layer_version" "crawler_updated_function_layer" {
  layer_name          = "updated-layer-${var.env}"
  description         = "Common dependencies for crawler functions"
  compatible_runtimes = ["nodejs14.x", "nodejs16.x", "nodejs18.x", "nodejs20.x"]
  filename            = "layer-${var.commit_hash}.zip"
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [null_resource.force_update]
}

resource "aws_iam_role" "updated_function_role" {
  name     = "updated-crawler-function-role-${var.env}"
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

resource "aws_iam_role_policy" "updated_function_s3_policy" {
  name = "updated-crawler-function-s3-policy-${var.env}"
  role = aws_iam_role.updated_function_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::minttown-pf-crawler-data-bucket-test/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "updated_function_role_policy" {
  role       = aws_iam_role.updated_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updated_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:us-west-2:${var.crawler_aws_account_id}:crawler-cross-account-notification"
}

resource "aws_sns_topic_subscription" "updated_function" {
  topic_arn = "arn:aws:sns:us-west-2:${var.crawler_aws_account_id}:crawler-cross-account-notification"
  protocol  = "lambda"
  endpoint  = aws_lambda_function.updated_function.arn
}
