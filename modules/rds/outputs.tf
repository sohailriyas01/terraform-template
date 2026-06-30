output "db_instance_id" {
  description = "Identifier of the DB instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the DB instance."
  value       = aws_db_instance.this.arn
}

output "address" {
  description = "Hostname of the database."
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "Connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "Port the database listens on."
  value       = aws_db_instance.this.port
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master credentials."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group attached to the database."
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}
