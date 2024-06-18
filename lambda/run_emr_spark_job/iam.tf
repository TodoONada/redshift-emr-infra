resource "aws_iam_role" "lambda_role" {
  name = "${var.env_prefix}-${var.service_name}-run-emr-spark-job-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.env_prefix}-${var.service_name}-run-emr-spark-job-lambda-policy"
  description = "IAM policy for ${var.env_prefix}-${var.service_name}-run-emr-spark-job-lambda-policy"

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
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "emr-serverless:StartJobRun",
          "emr-serverless:GetJobRun",
          "emr-serverless:ListJobRuns"
        ],
        Resource = [var.emr_serverless_spark_arn]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : [var.emr_serverless_role_arn],
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : "emr-serverless.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
