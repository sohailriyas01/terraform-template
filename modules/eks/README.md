# eks

An EKS cluster with managed node groups, IRSA, EKS-managed addons, access-entry auth, and
control-plane logging. Designed to sit on the private subnets of the [`vpc`](../vpc) module.

What it sets up:

- Control plane with the cluster IAM role and CloudWatch logging (you own the retention)
- One or more **managed node groups** with their own scaling, instance types, labels, and taints
- **IRSA** — an IAM OIDC provider so Kubernetes service accounts can assume IAM roles
- **Managed addons** — vpc-cni, CoreDNS, and kube-proxy by default
- **Access entries** — the API-based auth model that replaces the `aws-auth` ConfigMap

## Usage

```hcl
module "eks" {
  source = "github.com/sohailriyas01/terraform-template//modules/eks"

  name               = "prod"
  kubernetes_version = "1.31"
  subnet_ids         = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["m6i.large"]
      desired_size   = 3
      min_size       = 3
      max_size       = 6
    }
    spot = {
      capacity_type  = "SPOT"
      instance_types = ["m6i.large", "m5.large"]
      desired_size   = 2
      min_size       = 0
      max_size       = 10
      labels         = { workload = "batch" }
      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  # Grant a deploy role cluster-admin via an access entry.
  access_entries = {
    deployer = {
      principal_arn = aws_iam_role.deployer.arn
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    }
  }
}
```

The [`examples/complete`](./examples/complete) builds a VPC and a cluster together.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Cluster name and prefix | — |
| `kubernetes_version` | Control plane minor version | `1.31` |
| `subnet_ids` | Subnets for the control plane and nodes (private) | — |
| `endpoint_private_access` | API reachable from inside the VPC | `true` |
| `endpoint_public_access` | API reachable from the internet | `true` |
| `public_access_cidrs` | CIDRs allowed to the public endpoint | `["0.0.0.0/0"]` |
| `authentication_mode` | `API` or `API_AND_CONFIG_MAP` | `API` |
| `enable_irsa` | Create the IAM OIDC provider | `true` |
| `cluster_log_types` | Control plane logs to ship | `["api","audit","authenticator"]` |
| `cluster_log_retention_days` | Log group retention | `90` |
| `node_groups` | Managed node groups (see below) | one `default` group |
| `cluster_addons` | EKS-managed addons | vpc-cni, coredns, kube-proxy |
| `access_entries` | IAM principals granted access | `{}` |
| `tags` | Tags for all resources | `{}` |

### Node group fields

Per entry: `instance_types`, `capacity_type` (`ON_DEMAND`/`SPOT`), `ami_type`, `disk_size`,
`desired_size`, `min_size`, `max_size`, `max_unavailable`, `subnet_ids` (defaults to the
cluster subnets), `labels`, and `taints` (`{ key, value, effect }`).

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | Cluster name |
| `cluster_arn` | Cluster ARN |
| `cluster_endpoint` | API server endpoint |
| `cluster_certificate_authority_data` | Base64 CA cert for kubeconfig |
| `cluster_security_group_id` | EKS-managed cluster security group |
| `cluster_version` | Running Kubernetes version |
| `oidc_provider_arn` | OIDC provider ARN for IRSA |
| `oidc_provider_url` | OIDC issuer URL |
| `node_role_arn` | Shared node IAM role ARN |
| `node_group_names` | Managed node group names |

## Notes

- `desired_size` is the starting size only; it's `ignore_changes`d so a cluster autoscaler
  or Karpenter can own the count without Terraform fighting it.
- `bootstrap_cluster_creator_admin_permissions` is on, so whoever runs the apply gets
  cluster-admin. Grant everyone else access through `access_entries`.
- Lock down `public_access_cidrs` (or set `endpoint_public_access = false`) in production
  rather than leaving the API open to the internet.
- IRSA gives you the OIDC provider; build the per-workload IAM roles in the consuming config
  using `oidc_provider_arn`.
