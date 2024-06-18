provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Automation = "Terraform"
      Env        = var.environment
      Repo       = local.repo_name
    }
  }
}
