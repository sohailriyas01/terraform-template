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

# Uses the default VPC to keep the example self-contained. Real deployments should
# pass private subnets backed by a NAT gateway and drop assign_public_ip.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "this" {
  name = "fargate-demo"
}

module "service" {
  source = "../.."

  name        = "fargate-demo"
  cluster_arn = aws_ecs_cluster.this.arn

  vpc_id             = data.aws_vpc.default.id
  public_subnet_ids  = data.aws_subnets.default.ids
  private_subnet_ids = data.aws_subnets.default.ids

  container_image   = "public.ecr.aws/nginx/nginx:stable"
  container_port    = 80
  health_check_path = "/"

  desired_count    = 1
  min_capacity     = 1
  max_capacity     = 3
  assign_public_ip = true

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

output "url" {
  value = "http://${module.service.alb_dns_name}"
}
