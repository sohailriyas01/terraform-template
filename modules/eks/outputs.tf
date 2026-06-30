output "cluster_name" {
  description = "Name of the cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA certificate, for kubeconfig."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group EKS created and attached to the control plane and nodes."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = aws_eks_cluster.this.version
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA, or null when IRSA is disabled."
  value       = try(aws_iam_openid_connect_provider.this[0].arn, null)
}

output "oidc_provider_url" {
  description = "OIDC issuer URL for the cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_role_arn" {
  description = "IAM role ARN shared by the managed node groups."
  value       = aws_iam_role.node.arn
}

output "node_group_names" {
  description = "Names of the managed node groups."
  value       = keys(aws_eks_node_group.this)
}
