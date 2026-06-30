variable "bucket" {
  description = "Name of the bucket. Must be globally unique."
  type        = string
}

variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even when it still holds objects."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption. Falls back to SSE-S3 (AES256) when unset."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Use an S3 bucket key to cut KMS request costs. Only relevant with SSE-KMS."
  type        = bool
  default     = true
}

variable "enable_tls_enforcement" {
  description = "Attach a bucket policy denying any request not made over HTTPS."
  type        = bool
  default     = true
}

variable "logging_target_bucket" {
  description = "Bucket to deliver server access logs to. Logging is off when unset."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Key prefix for delivered access logs."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules. Each rule sets at least an id; the rest are optional."
  type = list(object({
    id                                 = string
    enabled                            = optional(bool, true)
    prefix                             = optional(string)
    abort_incomplete_multipart_days    = optional(number)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}
