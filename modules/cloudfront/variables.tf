variable "name" {
  description = "Name prefix for the distribution's resources."
  type        = string
}

variable "comment" {
  description = "Comment shown on the distribution in the console."
  type        = string
  default     = null
}

variable "origin_type" {
  description = "Origin kind: s3 (uses Origin Access Control) or custom (any HTTP origin)."
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["s3", "custom"], var.origin_type)
    error_message = "origin_type must be \"s3\" or \"custom\"."
  }
}

variable "origin_domain_name" {
  description = "Origin domain. For S3 use the bucket's regional domain name; for custom use the host."
  type        = string
}

variable "origin_protocol_policy" {
  description = "How CloudFront connects to a custom origin: http-only, https-only, or match-viewer."
  type        = string
  default     = "https-only"
}

variable "default_root_object" {
  description = "Object served for requests to the root path."
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Edge locations to use: PriceClass_100, PriceClass_200, or PriceClass_All."
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) for the distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for the aliases. Uses the default CloudFront cert when unset."
  type        = string
  default     = null
}

variable "viewer_protocol_policy" {
  description = "How viewers connect: allow-all, https-only, or redirect-to-https."
  type        = string
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "HTTP methods CloudFront forwards to the origin."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "HTTP methods CloudFront caches."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cache_policy_name" {
  description = "Managed cache policy to attach to the default behavior."
  type        = string
  default     = "Managed-CachingOptimized"
}

variable "origin_request_policy_id" {
  description = "Optional origin request policy ID for the default behavior."
  type        = string
  default     = null
}

variable "custom_error_responses" {
  description = "Custom error responses, e.g. mapping 403/404 to /index.html for single-page apps."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "geo_restriction_type" {
  description = "Geo restriction: none, whitelist, or blacklist."
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "Country codes for the geo restriction."
  type        = list(string)
  default     = []
}

variable "web_acl_id" {
  description = "WAFv2 web ACL ARN to associate with the distribution."
  type        = string
  default     = null
}

variable "logging_bucket" {
  description = "S3 bucket domain name for access logs. Logging is off when unset."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Key prefix for delivered access logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the distribution."
  type        = map(string)
  default     = {}
}
