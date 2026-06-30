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

  name       = "eks-demo"
  cidr_block = "10.30.0.0/16"
  az_count   = 2

  tags = {
    Environment = "demo"
  }
}

module "eks" {
  source = "../.."

  name               = "eks-demo"
  kubernetes_version = "1.31"
  subnet_ids         = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 2
      max_size       = 4
    }
  }

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
