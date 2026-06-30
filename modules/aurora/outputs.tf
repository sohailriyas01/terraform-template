output "cluster_id" {
  description = "Cluster identifier."
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "Cluster ARN."
  value       = aws_rds_cluster.this.arn
}

output "endpoint" {
  description = "Writer endpoint."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Load-balanced reader endpoint."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Port the cluster listens on."
  value       = aws_rds_cluster.this.port
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master credentials."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group attached to the cluster."
  value       = aws_security_group.this.id
}

output "instance_identifiers" {
  description = "Identifiers of the cluster instances."
  value       = aws_rds_cluster_instance.this[*].identifier
}
