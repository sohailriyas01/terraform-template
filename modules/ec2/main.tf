data "aws_ami" "al2023" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = coalesce(var.ami_id, try(data.aws_ami.al2023[0].id, null))

  # Flatten each ingress rule across its CIDRs so every (rule, cidr) is its own SG rule.
  ingress_rules = merge([
    for i, r in var.ingress_rules : {
      for cidr in r.cidr_blocks : "${i}-${cidr}" => {
        description = r.description
        from_port   = r.from_port
        to_port     = r.to_port
        protocol    = r.protocol
        cidr        = cidr
      }
    }
  ]...)
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = "Instance ${var.name}"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# SSM-enabled instance role so you can connect with Session Manager, no SSH key needed.

data "aws_iam_policy_document" "assume" {
  count = var.create_iam_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = var.create_iam_role ? 1 : 0
  name               = "${var.name}-instance"
  assume_role_policy = data.aws_iam_policy_document.assume[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.name}-instance"
  role  = aws_iam_role.this[0].name
  tags  = var.tags
}

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile
  monitoring                  = var.detailed_monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  # Require IMDSv2 to block SSRF-style credential theft.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags, { Name = var.name })
}
