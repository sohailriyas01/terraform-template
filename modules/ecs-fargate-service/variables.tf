variable "name" {
  description = "Name used for the service and as a prefix for created resources."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run the service in."
  type        = string
}

variable "vpc_id" {
  description = "VPC the load balancer and tasks live in."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets for the load balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the tasks. Use private subnets with a NAT gateway in production."
  type        = list(string)
}

variable "container_image" {
  description = "Container image, including tag or digest."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Task CPU units (256, 512, 1024, ...)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB. Must be a valid pairing with cpu for Fargate."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Initial task count. Autoscaling takes over after the first apply."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum tasks the service scales down to."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum tasks the service scales up to."
  type        = number
  default     = 6
}

variable "cpu_target_utilization" {
  description = "Average CPU percentage the autoscaler aims to hold."
  type        = number
  default     = 60
}

variable "health_check_path" {
  description = "Path the target group health check requests."
  type        = string
  default     = "/"
}

variable "environment" {
  description = "Plain environment variables passed to the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret env vars, mapping the container var name to a Secrets Manager or SSM parameter ARN."
  type        = map(string)
  default     = {}
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When set, the ALB serves HTTPS and redirects HTTP to it."
  type        = string
  default     = null
}

variable "internal" {
  description = "Whether the load balancer is internal (no public IP)."
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Give tasks a public IP. Needed only when they run in public subnets without a NAT gateway."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention for the service."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
