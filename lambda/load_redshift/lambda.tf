data "archive_file" "archive_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/archive.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.env_prefix}-${var.service_name}-load-redshift"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.archive_file.output_path
  source_code_hash = filebase64sha256(data.archive_file.archive_file.output_path)
  role             = aws_iam_role.lambda_role.arn
  timeout          = 900

  environment {
    variables = {
      REDSHIFT_CLUSTER_IDENTIFIER = var.redshift_cluster_identifier
      DATABASE_NAME         = var.database_name
      DATABASE_USER         = var.database_user
      TABLE_NAME            = var.table_name
      REDSHIFT_IAM_ROLE_ARN = var.redshift_iam_role_arn
    }
  }

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.input_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.input_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_function.lambda_function]
}