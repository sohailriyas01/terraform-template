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

module "table" {
  source = "../.."

  name      = "demo-orders"
  hash_key  = "pk"
  range_key = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
  ]

  global_secondary_indexes = [{
    name            = "gsi1"
    hash_key        = "gsi1pk"
    projection_type = "ALL"
  }]

  ttl_attribute = "expires_at"

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "table_arn" {
  value = module.table.table_arn
}
