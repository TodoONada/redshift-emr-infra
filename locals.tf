locals {
  service_name         = "redshift-emr-infra"
  repo_name            = "redshift-emr-infra"
  csv_transform_script = "csv_transform.py"
  pyspark_env_archive  = "pyspark_ge.tar.gz"

  env_prefixes         = {
    "development" = "dev"
    "staging"     = "stg"
    "production"  = "prod"
  }

  # 変数から環境名を取得してプレフィックスを選択
  env_prefix = lookup(local.env_prefixes, var.environment, "unknown")
}