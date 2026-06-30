# dynamodb

A DynamoDB table with point-in-time recovery and encryption on by default. Supports
secondary indexes, TTL, and streams. On-demand billing unless you switch to provisioned.

## Usage

```hcl
module "table" {
  source = "github.com/sohailriyas01/terraform-template//modules/dynamodb"

  name      = "orders"
  hash_key  = "pk"
  range_key = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
  ]

  global_secondary_indexes = [{
    name     = "gsi1"
    hash_key = "gsi1pk"
  }]

  ttl_attribute = "expires_at"
}
```

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Table name | — |
| `billing_mode` | `PAY_PER_REQUEST` or `PROVISIONED` | `PAY_PER_REQUEST` |
| `hash_key` | Partition key attribute | — |
| `range_key` | Sort key attribute | `null` |
| `attributes` | Key/index attribute definitions (`{ name, type }`) | — |
| `read_capacity` / `write_capacity` | Capacity (PROVISIONED only) | `null` |
| `global_secondary_indexes` | GSIs (see below) | `[]` |
| `local_secondary_indexes` | LSIs | `[]` |
| `ttl_attribute` | TTL timestamp attribute | `null` |
| `stream_enabled` | Enable streams | `false` |
| `stream_view_type` | Stream image type | `NEW_AND_OLD_IMAGES` |
| `point_in_time_recovery` | Enable PITR | `true` |
| `server_side_encryption` | Enable SSE | `true` |
| `kms_key_arn` | Customer-managed KMS key | `null` |
| `deletion_protection` | Block deletion | `false` |
| `tags` | Tags for the table | `{}` |

### GSI fields

Each GSI takes `name`, `hash_key`, and optionally `range_key`, `projection_type`
(default `ALL`), `non_key_attributes`, and `read_capacity`/`write_capacity` (PROVISIONED).
Any attribute used as a GSI/LSI key must also appear in `attributes`.

## Outputs

| Name | Description |
|------|-------------|
| `table_name` | Table name |
| `table_arn` | Table ARN |
| `table_id` | Table ID |
| `stream_arn` | Stream ARN (null if disabled) |

## Notes

- DynamoDB only needs key and index attributes declared in `attributes` — non-key
  attributes are schemaless and don't go here.
- Without a `kms_key_arn`, SSE uses the AWS-managed `aws/dynamodb` key at no extra cost.
