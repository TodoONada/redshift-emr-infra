# 入力用 S3 バケットの作成
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${local.env_prefix}-${local.service_name}-emr-input-s3"
}

resource "aws_s3_bucket_versioning" "input_bucket_versioning" {
  bucket = aws_s3_bucket.input_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# 出力用 S3 バケットの作成
resource "aws_s3_bucket" "output_bucket" {
  bucket = "${local.env_prefix}-${local.service_name}-emr-output-s3"
}

resource "aws_s3_bucket_versioning" "output_bucket_versioning" {
  bucket = aws_s3_bucket.output_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Sparkジョブスクリプトの配置先
resource "aws_s3_bucket" "script_bucket" {
  bucket = "${local.env_prefix}-${local.service_name}-emr-script-s3"
}

resource "aws_s3_bucket_versioning" "script_bucket_versioning" {
  bucket = aws_s3_bucket.script_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "script_object" {
  bucket = aws_s3_bucket.script_bucket.bucket
  key    = local.csv_transform_script # アップロードするファイルのS3上のパス
  source = "./script/${local.csv_transform_script}" # ローカルシステム上のファイルのパス

  # オプション: ファイルの内容が変わったときだけアップロードをトリガーする
  etag = filemd5("./script/${local.csv_transform_script}")
}

resource "aws_s3_object" "script_venv_object" {
  bucket = aws_s3_bucket.script_bucket.bucket
  key    = local.pyspark_env_archive # アップロードするファイルのS3上のパス
  source = "./emr_python_library/${local.pyspark_env_archive}" # ローカルシステム上のファイルのパス

  # オプション: ファイルの内容が変わったときだけアップロードをトリガーする
  etag = filemd5("./emr_python_library/${local.pyspark_env_archive}")
}