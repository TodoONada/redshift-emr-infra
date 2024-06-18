variable "environment" {
  description = "The environment to deploy into"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "database_name" {
  description = "The name of the database"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "The master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "The master password for the database"
  type        = string
  default     = "password"
}
