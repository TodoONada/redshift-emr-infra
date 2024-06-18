resource "aws_emrserverless_application" "emr_serverless_spark" {
  name        = "${local.env_prefix}-${local.service_name}-serverless-spark"
  release_label = "emr-7.0.0"

  type = "spark"

  initial_capacity {
    initial_capacity_type = "Driver"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "2 vCPU"
        memory = "10 GB"
      }
    }
  }

  maximum_capacity {
    cpu    = "32 vCPU"
    memory = "128 GB"
    disk   = "1024 GB"
  }

  auto_stop_configuration {
    enabled = true
    idle_timeout_minutes = 15
  }

}