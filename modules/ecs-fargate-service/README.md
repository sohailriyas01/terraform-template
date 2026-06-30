# ecs-fargate-service

Runs a container as an ECS Fargate service behind an Application Load Balancer, with
CPU-based autoscaling, CloudWatch logging, and task/execution IAM roles. Optionally
terminates TLS with an ACM certificate and redirects HTTP to HTTPS.

The module manages the service, not the cluster or network. Pass it an existing cluster
ARN, a VPC, and subnets.

## Usage

```hcl
module "api" {
  source = "github.com/sohailriyas01/terraform-template//modules/ecs-fargate-service"

  name        = "api"
  cluster_arn = aws_ecs_cluster.main.arn

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:1.4.0"
  container_port  = 8080

  desired_count = 2
  min_capacity  = 2
  max_capacity  = 10

  certificate_arn = aws_acm_certificate.api.arn

  environment = {
    LOG_LEVEL = "info"
  }

  secrets = {
    DATABASE_URL = aws_secretsmanager_secret.db.arn
  }

  tags = {
    Service = "api"
  }
}
```

A complete, runnable setup is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Service name and resource prefix | — |
| `cluster_arn` | ECS cluster to run in | — |
| `vpc_id` | VPC for the ALB and tasks | — |
| `public_subnet_ids` | Subnets for the load balancer | — |
| `private_subnet_ids` | Subnets for the tasks | — |
| `container_image` | Image with tag or digest | — |
| `container_port` | Port the container listens on | `8080` |
| `cpu` / `memory` | Fargate task size | `256` / `512` |
| `desired_count` | Initial task count | `2` |
| `min_capacity` / `max_capacity` | Autoscaling bounds | `2` / `6` |
| `cpu_target_utilization` | Target CPU % for scaling | `60` |
| `health_check_path` | Target group health check path | `/` |
| `environment` | Plain env vars | `{}` |
| `secrets` | Env var name to Secrets Manager / SSM ARN | `{}` |
| `certificate_arn` | ACM cert; enables HTTPS when set | `null` |
| `internal` | Internal load balancer | `false` |
| `assign_public_ip` | Public IP on tasks (no-NAT setups) | `false` |
| `log_retention_days` | CloudWatch retention | `30` |
| `tags` | Tags for all resources | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `alb_dns_name` | Load balancer DNS name |
| `alb_arn` | Load balancer ARN |
| `target_group_arn` | Target group ARN |
| `service_name` | ECS service name |
| `task_definition_arn` | Active task definition ARN |
| `task_role_arn` | Task role for application permissions |
| `security_group_id` | Security group on the tasks |
| `log_group_name` | CloudWatch log group |

## Notes

- `desired_count` only sets the starting size. Autoscaling owns the count afterward, so
  changes to it are ignored on later applies — adjust `min_capacity`/`max_capacity` instead.
- The task role starts empty. Attach policies to `task_role_arn` for whatever the app needs.
- Deployment circuit breaker is on, so a failed rollout rolls back automatically.
