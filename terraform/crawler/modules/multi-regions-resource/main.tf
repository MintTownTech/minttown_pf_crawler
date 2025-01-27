# Lambda Function (Account Crawler)
resource "aws_lambda_layer_version" "crawler_function_layer" {
  layer_name          = "crawler-layer"
  description         = "Common dependencies for crawler functions"
  compatible_runtimes = ["nodejs14.x", "nodejs16.x", "nodejs18.x", "nodejs20.x"]
  filename            = "layer-${var.commit_hash}.zip"
}

resource "aws_lambda_function" "crawler_function" {
  function_name = "crawler-function-main"
  filename        = "source-${var.commit_hash}.zip"
  role          = var.crawler_function_role
  handler       = "dist/lambda_handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30  # Increase the timeout to 30 seconds
  layers        = [aws_lambda_layer_version.crawler_function_layer.arn]

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
      S3_BUCKET     = var.s3_bucket_name
      FREECASH_SESSION_ID = var.freecash_session_id
      COUNTRY = var.country
    }
  }
}
