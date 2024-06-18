variable "service_name" {
  description = "Service name"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "application_id" {
  description = "EMR Serverless Application ID"
  type        = string
}

variable "output_bucket" {
  description = "Output bucket"
  type        = string
}

variable "entry_point" {
  description = "Entry point"
  type        = string
}


variable "spark_submit_parameters" {
  description = "Spark submit parameters"
  type        = string
}


variable "emr_serverless_role_arn" {
  description = "EMR Serverless Role ARN"
  type        = string
}

variable "emr_serverless_spark_arn" {
  description = "EMR Serverless Spark ARN"
  type        = string
}

variable "input_bucket_id" {
  description = "Input bucket ID"
  type        = string
}

variable "input_bucket_arn" {
  description = "Input bucket ARN"
  type        = string
}