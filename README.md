# terraform-template

Reusable Terraform modules for AWS, with secure defaults and a runnable example for each.
Each module is self-contained, parameterized, and documented — copy the source line and go.

## Modules

| Module | Description |
|--------|-------------|
| [`vpc`](./modules/vpc) | VPC with public and private subnets across AZs, an internet gateway, and NAT gateways. |
| [`ec2`](./modules/ec2) | EC2 instance with an encrypted root volume, IMDSv2, and an optional SSM role for keyless access. |
| [`ecs-fargate-service`](./modules/ecs-fargate-service) | A container on ECS Fargate behind an Application Load Balancer, with CPU autoscaling. |
| [`eks`](./modules/eks) | EKS cluster with managed node groups, IRSA, managed addons, and access-entry auth. |
| [`rds`](./modules/rds) | Managed RDS instance (Postgres/MySQL/MariaDB) with encryption and a Secrets Manager-managed password. |
| [`aurora`](./modules/aurora) | Aurora cluster (Postgres/MySQL), provisioned or Serverless v2, with writer and reader endpoints. |
| [`dynamodb`](./modules/dynamodb) | DynamoDB table with PITR, encryption, secondary indexes, TTL, and streams. |
| [`s3-bucket`](./modules/s3-bucket) | General-purpose S3 bucket with public access blocked, encryption, versioning, and TLS-only access. |
| [`cloudfront`](./modules/cloudfront) | CloudFront distribution for a private S3 origin (OAC) or a custom origin, HTTPS enforced. |

## Usage

Reference a module by its path within this repo:

```hcl
module "vpc" {
  source = "github.com/sohailriyas01/terraform-template//modules/vpc"

  name     = "prod"
  az_count = 3
}
```

Pin to a tag for stability once you start tagging releases:

```hcl
source = "github.com/sohailriyas01/terraform-template//modules/vpc?ref=v1.0.0"
```

The `vpc` and `ecs-fargate-service` modules compose — feed the VPC's `vpc_id` and subnet
outputs straight into the service.

## Requirements

- Terraform >= 1.5
- AWS provider >= 6.0

## Conventions

- Provider versions are pinned; no `latest`.
- No secrets or account-specific values are baked into modules — everything comes through inputs.
- Secure defaults: least-privilege IAM, encryption on, public access blocked.
- Every module ships with a `README.md` and an `examples/complete` you can `terraform plan`.

## Layout

```
modules/
  <name>/
    main.tf
    variables.tf
    outputs.tf
    versions.tf
    README.md
    examples/complete/
```
