resource "aws_iam_role" "lambda_role" {
  name = "${var.env_prefix}-${var.service_name}-load-redshift-lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.env_prefix}-${var.service_name}-load-redshift-lambda-policy"
  description = "IAM policy for ${var.env_prefix}-${var.service_name}-load-redshift-lambda-policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.log_group.arn,
          "${aws_cloudwatch_log_group.log_group.arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "redshift-data:ExecuteStatement",
          "redshift:GetClusterCredentials",
        ]
        Resource = ["*"]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
