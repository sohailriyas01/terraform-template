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

# Suffix with the account ID so the example name is unique enough to apply.
data "aws_caller_identity" "current" {}

module "bucket" {
  source = "../.."

  bucket     = "demo-artifacts-${data.aws_caller_identity.current.account_id}"
  versioning = true

  lifecycle_rules = [{
    id                                 = "expire-old-versions"
    abort_incomplete_multipart_days    = 7
    noncurrent_version_expiration_days = 90
    transitions = [{
      days          = 30
      storage_class = "STANDARD_IA"
    }]
  }]

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "bucket_arn" {
  value = module.bucket.bucket_arn
}
