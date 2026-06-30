locals {
  default_ports = {
    aurora-postgresql = 5432
    aurora-mysql      = 3306
  }
  port = coalesce(var.port, lookup(local.default_ports, var.engine, 5432))
}

resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = "Aurora ${var.name}"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  description       = "DB access"
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  description                  = "DB access"
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = var.name
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  port               = local.port

  # Master password managed and rotated by RDS in Secrets Manager.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final"

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverless ? [1] : []
    content {
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.name}-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = var.serverless ? "db.serverless" : var.instance_class

  db_subnet_group_name         = aws_db_subnet_group.this.name
  performance_insights_enabled = var.performance_insights_enabled

  tags = var.tags
}
