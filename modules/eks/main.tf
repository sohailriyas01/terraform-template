# Cluster IAM role

data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Control plane logging. Created up front so we own the retention instead of letting
# EKS create the log group with never-expire defaults.
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.cluster_log_retention_days
  tags              = var.tags
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_cloudwatch_log_group.cluster,
  ]

  tags = var.tags
}

# IRSA: trust the cluster's OIDC issuer so service accounts can assume IAM roles.

data "tls_certificate" "oidc" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.enable_irsa ? 1 : 0
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc[0].certificates[0].sha1_fingerprint]
  tags            = var.tags
}

# Node IAM role

data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.name}-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])

  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# Managed node groups

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = coalesce(each.value.subnet_ids, var.subnet_ids)
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  ami_type        = each.value.ami_type
  disk_size       = each.value.disk_size
  labels          = each.value.labels

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  # A cluster autoscaler or Karpenter manages the running size after creation.
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_iam_role_policy_attachment.node]

  tags = var.tags
}

# Addons last, so CoreDNS has nodes to schedule on.

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]

  tags = var.tags
}

# Access entries (modern replacement for the aws-auth ConfigMap)

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  type          = each.value.type
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "this" {
  for_each = var.access_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope_type
    namespaces = each.value.access_scope_type == "namespace" ? each.value.namespaces : null
  }

  depends_on = [aws_eks_access_entry.this]
}
