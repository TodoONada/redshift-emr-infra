# IAM Role for EMR Serverless
resource "aws_iam_role" "emr_serverless_role" {
  name = "${local.env_prefix}-${local.service_name}-emr-serverless-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "emr-serverless.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_serverless_policy_attachment" {
  role       = aws_iam_role.emr_serverless_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "emr_serverless_s3_policy" {
  name        = "${local.env_prefix}-${local.service_name}-emr-serverless-s3-policy"
  description = "Policy for EMR Serverless to access S3"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*",
          aws_s3_bucket.output_bucket.arn,
          "${aws_s3_bucket.output_bucket.arn}/*",
          aws_s3_bucket.script_bucket.arn,
          "${aws_s3_bucket.script_bucket.arn}/*",
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "emr_serverless_s3_policy_attachment" {
  role       = aws_iam_role.emr_serverless_role.id
  policy_arn = aws_iam_policy.emr_serverless_s3_policy.arn
}


resource "aws_iam_role" "redshift_role" {
  name = "${local.env_prefix}-${local.service_name}-redshift-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "redshift_policy" {
  name   = "${local.env_prefix}-${local.service_name}-redshift-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "redshift-data:ExecuteStatement"
        ],
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "redshift:GetClusterCredentials"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_policy_attachment" {
  role       = aws_iam_role.redshift_role.id
  policy_arn = aws_iam_policy.redshift_policy.arn
}