locals {
  default_ports = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
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
  description = "RDS ${var.name}"
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

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  port     = local.port

  # RDS generates and rotates the master password in Secrets Manager, so it never
  # touches Terraform state.
  manage_master_user_password = true

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = var.parameter_group_name

  backup_retention_period      = var.backup_retention_period
  performance_insights_enabled = var.performance_insights_enabled

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final"

  tags = var.tags
}
