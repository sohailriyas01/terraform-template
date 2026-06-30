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

  name     = "rds-demo"
  az_count = 2

  tags = {
    Environment = "demo"
  }
}

module "db" {
  source = "../.."

  name       = "rds-demo"
  engine     = "postgres"
  db_name    = "app"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Demo settings so it can be torn down cleanly.
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "endpoint" {
  value = module.db.endpoint
}

output "master_user_secret_arn" {
  value = module.db.master_user_secret_arn
}
