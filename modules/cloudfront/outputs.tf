output "distribution_id" {
  description = "ID of the distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "ARN of the distribution. Use this in an S3 bucket policy to allow the OAC."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "CloudFront domain name (e.g. dxxxx.cloudfront.net)."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront hosted zone ID, for Route 53 alias records."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_control_id" {
  description = "OAC ID, or null for custom origins."
  value       = try(aws_cloudfront_origin_access_control.this[0].id, null)
}
