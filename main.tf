terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.3"
  backend "s3" {}
}


resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(
    {
      Name = "${local.env_prefix}-${local.service_name}-vpc"
    },
  )
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${local.env_prefix}-${local.service_name}-internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  count  = 3
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env_prefix}-${local.service_name}-public-route-table-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags                    = merge(
    {
      Name = "${local.env_prefix}-${local.service_name}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    },
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "default_sg" {
  name        = "${local.env_prefix}-${local.service_name}-default-sg"
  description = "Default security group for VPC"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${local.env_prefix}-${local.service_name}-default-sg"
    },
  )
}

module "run_emr_spark_job" {
  source                   = "./lambda/run_emr_spark_job"
  service_name             = local.service_name
  env_prefix               = local.env_prefix
  application_id           = aws_emrserverless_application.emr_serverless_spark.id
  output_bucket            = aws_s3_bucket.output_bucket.bucket
  entry_point              = "s3://${aws_s3_bucket.script_bucket.bucket}/${local.csv_transform_script}"
  spark_submit_parameters  = "--conf spark.archives=s3://${aws_s3_bucket.script_bucket.bucket}/${local.pyspark_env_archive}#environment --conf spark.emr-serverless.driverEnv.PYSPARK_DRIVER_PYTHON=./environment/bin/python --conf spark.emr-serverless.driverEnv.PYSPARK_PYTHON=./environment/bin/python --conf spark.executorEnv.PYSPARK_PYTHON=./environment/bin/python"
  emr_serverless_role_arn  = aws_iam_role.emr_serverless_role.arn
  emr_serverless_spark_arn = aws_emrserverless_application.emr_serverless_spark.arn
  input_bucket_id          = aws_s3_bucket.input_bucket.id
  input_bucket_arn         = aws_s3_bucket.input_bucket.arn
}

module "load_redshift" {
  source                      = "./lambda/load_redshift"
  service_name                = local.service_name
  env_prefix                  = local.env_prefix
  database_name               = var.database_name
  database_user               = var.master_username
  table_name                  = "診断履歴"
  redshift_cluster_identifier = aws_redshift_cluster.redshift_cluster.id
  redshift_iam_role_arn       = aws_iam_role.redshift_role.arn
  input_bucket                = aws_s3_bucket.output_bucket.bucket
  input_bucket_arn            = aws_s3_bucket.output_bucket.arn
  input_bucket_id             = aws_s3_bucket.output_bucket.id
}