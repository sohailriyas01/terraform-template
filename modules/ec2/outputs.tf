output "instance_id" {
  description = "ID of the instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP, if one was assigned."
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "Security group attached to the instance."
  value       = aws_security_group.this.id
}

output "iam_role_arn" {
  description = "Instance IAM role ARN, or null when none was created."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "ami_id" {
  description = "AMI the instance was launched from."
  value       = local.ami_id
}
