variable "name" {
  description = "Name for the instance and its resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the security group in."
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instance in."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI to use. Defaults to the latest Amazon Linux 2023 when unset."
  type        = string
  default     = null
}

variable "key_name" {
  description = "EC2 key pair for SSH. Leave unset and use SSM Session Manager instead."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Assign a public IP. Keep false for instances in private subnets."
  type        = bool
  default     = false
}

variable "create_iam_role" {
  description = "Create an instance role with SSM access so you can connect without SSH."
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "Existing instance profile to attach. Used only when create_iam_role is false."
  type        = string
  default     = null
}

variable "ingress_rules" {
  description = "Inbound rules for the instance security group."
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = optional(string, "tcp")
    cidr_blocks = list(string)
  }))
  default = []
}

variable "user_data" {
  description = "User data script. Rendered on first boot."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "detailed_monitoring" {
  description = "Enable detailed (1-minute) CloudWatch monitoring."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
