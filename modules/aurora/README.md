# aurora

An Aurora cluster (PostgreSQL or MySQL) with a writer and optional readers, encryption,
automated backups, and a security group. Runs either fixed-size provisioned instances or
Aurora Serverless v2. The master password is managed and rotated by RDS in Secrets Manager.

## Usage

Provisioned, with a writer and a reader:

```hcl
module "aurora" {
  source = "github.com/sohailriyas01/terraform-template//modules/aurora"

  name           = "app-prod"
  engine         = "aurora-postgresql"
  database_name  = "app"
  instance_class = "db.r6g.large"
  instance_count = 2

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.service.security_group_id]
}
```

Serverless v2:

```hcl
module "aurora" {
  source = "github.com/sohailriyas01/terraform-template//modules/aurora"

  name         = "app"
  serverless   = true
  min_capacity = 0.5
  max_capacity = 8

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
```

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Cluster identifier and prefix | — |
| `engine` | `aurora-postgresql` or `aurora-mysql` | `aurora-postgresql` |
| `engine_version` | Engine version | `null` |
| `serverless` | Use Serverless v2 | `false` |
| `instance_class` | Class for provisioned instances | `db.t4g.medium` |
| `min_capacity` / `max_capacity` | Serverless v2 ACU range | `0.5` / `4` |
| `instance_count` | Cluster instances (writer + readers) | `2` |
| `database_name` | Initial database name | `null` |
| `master_username` | Master username | `dbadmin` |
| `port` | Listen port | engine default |
| `vpc_id` | VPC for the security group | — |
| `subnet_ids` | Subnets for the DB subnet group | — |
| `allowed_cidr_blocks` | CIDRs allowed to connect | `[]` |
| `allowed_security_group_ids` | SGs allowed to connect | `[]` |
| `kms_key_id` | KMS key for encryption | `null` |
| `backup_retention_period` | Backup retention (days) | `7` |
| `performance_insights_enabled` | Performance Insights | `true` |
| `deletion_protection` | Block deletion | `true` |
| `skip_final_snapshot` | Skip final snapshot on destroy | `false` |
| `tags` | Tags for all resources | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | Cluster identifier |
| `cluster_arn` | Cluster ARN |
| `endpoint` | Writer endpoint |
| `reader_endpoint` | Reader endpoint |
| `port` | Port |
| `master_user_secret_arn` | Secrets Manager ARN for the master credentials |
| `security_group_id` | Cluster security group |
| `instance_identifiers` | Cluster instance identifiers |

## Notes

- With `serverless = true` the `instance_class` is ignored — instances run as
  `db.serverless` and scale between `min_capacity` and `max_capacity` ACUs.
- The first instance is the writer; any beyond that are readers served by `reader_endpoint`.
- `deletion_protection` defaults to `true` and `skip_final_snapshot` to `false`. Flip both
  for throwaway environments.
