variable "name" {
  description = "Name prefix for the VPC and its resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across. Ignored when azs is set."
  type        = number
  default     = 2
}

variable "azs" {
  description = "Explicit availability zones to use. Defaults to the first az_count zones in the region."
  type        = list(string)
  default     = []
}

variable "subnet_newbits" {
  description = "Bits added to the VPC prefix to size each subnet. With a /16 VPC, 8 gives /24 subnets."
  type        = number
  default     = 8
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways so private subnets can reach the internet."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ. Cheaper, but a zone outage cuts private egress."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
