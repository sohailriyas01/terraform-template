terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../.."

  name       = "demo"
  cidr_block = "10.20.0.0/16"
  az_count   = 2

  # One NAT for the whole VPC keeps the demo cheap. Set false for one per AZ.
  single_nat_gateway = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
