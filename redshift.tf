resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier      = "${local.env_prefix}-${local.service_name}-cluster"
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  node_type               = "dc2.large"
  cluster_type            = "single-node"

  # 暗号化の設定
  encrypted               = true

  # セキュリティグループとサブネットグループの指定
  vpc_security_group_ids  = [aws_security_group.redshift_sg.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name

  iam_roles               = [aws_iam_role.redshift_role.arn]
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${local.env_prefix}-${local.service_name}-redshift-subnet-group"
  subnet_ids = aws_subnet.public_subnet[*].id

  tags = {
    Name = "${local.env_prefix}-${local.service_name}-redshift-subnet-group"
  }
}

resource "aws_security_group" "redshift_sg" {
  name        = "${local.env_prefix}-${local.service_name}-redshift-sg"
  description = "Security group for RedShift clusters"
  vpc_id      = aws_vpc.vpc.id

  # Redshiftへのアクセス制限はここで行う
  ingress {
    description = "Redshift access"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env_prefix}-${local.service_name}-redshift-sg"
  }
}