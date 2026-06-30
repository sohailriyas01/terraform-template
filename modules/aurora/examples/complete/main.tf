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
  source = "../../../vpc"

  name     = "aurora-demo"
  az_count = 2

  tags = {
    Environment = "demo"
  }
}

module "aurora" {
  source = "../.."

  name          = "aurora-demo"
  engine        = "aurora-postgresql"
  database_name = "app"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Serverless v2 with a single instance keeps the demo small.
  serverless     = true
  min_capacity   = 0.5
  max_capacity   = 2
  instance_count = 1

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "endpoint" {
  value = module.aurora.endpoint
}

output "reader_endpoint" {
  value = module.aurora.reader_endpoint
}
