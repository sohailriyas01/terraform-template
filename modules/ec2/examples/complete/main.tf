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

  name     = "ec2-demo"
  az_count = 2

  tags = {
    Environment = "demo"
  }
}

module "instance" {
  source = "../.."

  name          = "ec2-demo"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_subnet_ids[0]
  instance_type = "t3.micro"

  # No public IP, no SSH key — connect via SSM Session Manager.
  associate_public_ip = false
  create_iam_role     = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "instance_id" {
  value = module.instance.instance_id
}

output "private_ip" {
  value = module.instance.private_ip
}
