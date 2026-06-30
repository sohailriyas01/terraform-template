output "table_name" {
  description = "Name of the table."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the table."
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID of the table."
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN of the table stream, or null when streams are disabled."
  value       = try(aws_dynamodb_table.this.stream_arn, null)
}
