variable "service_name" {
  description = "Service name"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "redshift_cluster_identifier" {
  description = "Redshift cluster identifier"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_user" {
  description = "Database user"
  type        = string
}

variable "table_name" {
  description = "Table name"
  type        = string
}

variable "redshift_iam_role_arn" {
  description = "Redshift IAM Role ARN"
  type        = string
}

variable "input_bucket" {
  description = "Input bucket"
  type        = string
}

variable "input_bucket_arn" {
  description = "Input bucket ARN"
  type        = string
}

variable "input_bucket_id" {
  description = "Input bucket ID"
  type        = string
}