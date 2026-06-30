variable "name" {
  description = "Table name."
  type        = string
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name."
  type        = string
  default     = null
}

variable "attributes" {
  description = "Attribute definitions for keys and indexes. Type is S, N, or B."
  type = list(object({
    name = string
    type = string
  }))
}

variable "read_capacity" {
  description = "Read capacity units. Only used with PROVISIONED billing."
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units. Only used with PROVISIONED billing."
  type        = number
  default     = null
}

variable "global_secondary_indexes" {
  description = "Global secondary indexes."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Local secondary indexes."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "ttl_attribute" {
  description = "Attribute holding the TTL timestamp. TTL is off when unset."
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "What is written to the stream: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery."
  type        = bool
  default     = true
}

variable "server_side_encryption" {
  description = "Enable server-side encryption with a KMS key (AWS-managed unless kms_key_arn is set)."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN for encryption. Uses the AWS-managed key when unset."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Block the table from being deleted."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the table."
  type        = map(string)
  default     = {}
}
