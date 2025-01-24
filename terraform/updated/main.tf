resource "aws_lambda_function" "updated_function" {
  function_name = "lambda_updated_function"
  filename        = "./lambda_function.zip"
  role          = aws_iam_role.updated_function_role.arn
  handler       = "dist/updated_handler.handler"
  runtime       = "nodejs20.x"
  timeout       = 30  # Increase the timeout to 30 seconds
}

resource "aws_lambda_layer_version" "crawler_updated_function_layer" {
  layer_name          = "crawler_updated_function_layer"
  description         = "Common dependencies for crawler functions"
  compatible_runtimes = ["nodejs14.x", "nodejs16.x", "nodejs18.x", "nodejs20.x"]
  filename            = "layer.zip"
  source_code_hash    = filebase64sha256("layer.zip")
}

resource "aws_iam_role" "updated_function_role" {
  name     = "updated_function_role"
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
  name = "updated_function_s3_policy"
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
  source_arn    = "arn:aws:sns:us-west-2:340258365836:crawler-cross-account-notification"
}

resource "aws_sns_topic_subscription" "updated_function" {
  topic_arn = "arn:aws:sns:us-west-2:340258365836:crawler-cross-account-notification"
  protocol  = "lambda"
  endpoint  = aws_lambda_function.updated_function.arn
}