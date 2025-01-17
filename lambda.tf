data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-lambdaRole-waf"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambdas/python/api_lambda/app.py"
  output_path = "${path.module}/lambdas/archive/api_app.zip"
}

resource "aws_lambda_function" "api_gateway_lambda" {
  function_name    = "api_gateway_response"
  filename         = "${path.module}/lambdas/archive/api_app.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "app.lambda_handler"
  timeout          = 10
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_gateway_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/*"
}

resource "aws_iam_policy" "wafv2_policy" {
  name   = "wafv2_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.wafv2_policy.json
}

data "aws_iam_policy_document" "wafv2_policy" {


  statement {
    effect = "Allow"

    actions = [
      "wafv2:Get*",
      "wafv2:Update*"
    ]

    resources = [aws_cloudfront_distribution.this.arn]
  }
}

resource "aws_iam_role_policy_attachment" "wafv2_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.wafv2_policy.arn
}