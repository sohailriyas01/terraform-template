# rds

A managed RDS instance (PostgreSQL, MySQL, or MariaDB) with encryption, automated backups,
storage autoscaling, and a security group you open to specific CIDRs or security groups.
The master password is generated and rotated by RDS in Secrets Manager, so it never lands
in Terraform state.

## Usage

```hcl
module "db" {
  source = "github.com/sohailriyas01/terraform-template//modules/rds"

  name       = "app-prod"
  engine     = "postgres"
  db_name    = "app"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  instance_class = "db.t4g.medium"
  multi_az       = true

  allowed_security_group_ids = [module.service.security_group_id]
}
```

The app reads the connection secret from `master_user_secret_arn`.

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | DB identifier and prefix | — |
| `engine` | `postgres`, `mysql`, or `mariadb` | `postgres` |
| `engine_version` | Engine version | `null` (provider default) |
| `instance_class` | Instance class | `db.t3.micro` |
| `allocated_storage` | Initial storage (GiB) | `20` |
| `max_allocated_storage` | Autoscaling ceiling (GiB) | `100` |
| `storage_type` | Storage type | `gp3` |
| `kms_key_id` | KMS key for encryption | `null` |
| `db_name` | Initial database name | `null` |
| `username` | Master username | `dbadmin` |
| `port` | Listen port | engine default |
| `vpc_id` | VPC for the security group | — |
| `subnet_ids` | Subnets for the DB subnet group | — |
| `allowed_cidr_blocks` | CIDRs allowed to connect | `[]` |
| `allowed_security_group_ids` | SGs allowed to connect | `[]` |
| `multi_az` | Standby in another AZ | `false` |
| `backup_retention_period` | Backup retention (days) | `7` |
| `performance_insights_enabled` | Performance Insights | `true` |
| `deletion_protection` | Block deletion | `true` |
| `skip_final_snapshot` | Skip final snapshot on destroy | `false` |
| `parameter_group_name` | Existing parameter group | `null` |
| `tags` | Tags for all resources | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `db_instance_id` | DB identifier |
| `db_instance_arn` | DB ARN |
| `address` | Hostname |
| `endpoint` | host:port |
| `port` | Port |
| `master_user_secret_arn` | Secrets Manager ARN for the master credentials |
| `security_group_id` | DB security group |
| `subnet_group_name` | DB subnet group |

## Notes

- `deletion_protection` defaults to `true` and `skip_final_snapshot` to `false`, so the
  database resists accidental loss. Flip both for throwaway environments.
- Grant access by passing app security groups to `allowed_security_group_ids` rather than
  widening CIDRs — it's tighter and survives IP changes.
