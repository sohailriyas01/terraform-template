variable "name" {
  description = "Cluster identifier and resource prefix."
  type        = string
}

variable "engine" {
  description = "Aurora engine: aurora-postgresql or aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Engine version. Leave unset for the provider default."
  type        = string
  default     = null
}

variable "serverless" {
  description = "Run Aurora Serverless v2 instead of fixed-size instances."
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "Instance class for provisioned instances. Ignored when serverless is true."
  type        = string
  default     = "db.t4g.medium"
}

variable "min_capacity" {
  description = "Serverless v2 minimum ACUs."
  type        = number
  default     = 0.5
}

variable "max_capacity" {
  description = "Serverless v2 maximum ACUs."
  type        = number
  default     = 4
}

variable "instance_count" {
  description = "Number of cluster instances (one writer, the rest readers)."
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Name of the initial database."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Master username."
  type        = string
  default     = "dbadmin"
}

variable "port" {
  description = "Port to listen on. Defaults to the engine's standard port."
  type        = number
  default     = null
}

variable "vpc_id" {
  description = "VPC to create the security group in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group. Use private subnets."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to connect to the cluster."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the cluster."
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key for storage encryption. Uses the default RDS key when unset."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Days to keep automated backups."
  type        = number
  default     = 7
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights on the instances."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Block the cluster from being deleted."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Leave false outside throwaway environments."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
