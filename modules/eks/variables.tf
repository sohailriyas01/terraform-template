variable "name" {
  description = "Cluster name and resource prefix."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane."
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "Subnets for the control plane ENIs and, by default, the node groups. Use private subnets."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Allow access to the API server from within the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Allow access to the API server from the internet."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Narrow this in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "authentication_mode" {
  description = "Cluster auth mode. API uses access entries; API_AND_CONFIG_MAP also keeps the aws-auth ConfigMap."
  type        = string
  default     = "API"
}

variable "enable_irsa" {
  description = "Create an IAM OIDC provider so service accounts can assume IAM roles (IRSA)."
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "Control plane log types to ship to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "cluster_log_retention_days" {
  description = "Retention for the control plane log group."
  type        = number
  default     = 90
}

variable "node_groups" {
  description = "Managed node groups, keyed by name."
  type = map(object({
    instance_types  = optional(list(string), ["t3.medium"])
    capacity_type   = optional(string, "ON_DEMAND")
    ami_type        = optional(string)
    disk_size       = optional(number, 20)
    desired_size    = optional(number, 2)
    min_size        = optional(number, 1)
    max_size        = optional(number, 3)
    max_unavailable = optional(number, 1)
    subnet_ids      = optional(list(string))
    labels          = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
  default = {
    default = {}
  }
}

variable "cluster_addons" {
  description = "EKS-managed addons, keyed by addon name. Version is optional (defaults to the EKS default)."
  type = map(object({
    version = optional(string)
  }))
  default = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }
}

variable "access_entries" {
  description = "IAM principals granted cluster access, keyed by a label."
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    policy_arn        = string
    access_scope_type = optional(string, "cluster")
    namespaces        = optional(list(string))
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
