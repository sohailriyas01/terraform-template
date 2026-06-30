variable "name" {
  description = "DB identifier and resource prefix."
  type        = string
}

variable "engine" {
  description = "Database engine: postgres, mysql, or mariadb."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version. Leave unset to take the provider's default for the engine."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "DB instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper bound for storage autoscaling. Set equal to allocated_storage to disable it."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "EBS storage type for the instance."
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS key for storage encryption. Uses the default RDS key when unset."
  type        = string
  default     = null
}

variable "db_name" {
  description = "Name of the initial database to create."
  type        = string
  default     = null
}

variable "username" {
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
  description = "CIDRs allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Run a standby in another AZ for failover."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to keep automated backups."
  type        = number
  default     = 7
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Block the instance from being deleted."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Leave false outside throwaway environments."
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Existing DB parameter group to attach."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
