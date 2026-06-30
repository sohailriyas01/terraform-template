# s3-bucket

A general-purpose S3 bucket with the security settings you'd otherwise re-add by hand on
every bucket:

- Public access fully blocked (all four account-level settings on)
- ACLs disabled (`BucketOwnerEnforced`)
- Encryption at rest — SSE-S3 by default, SSE-KMS when you pass a key
- Versioning on by default
- A bucket policy that denies any non-HTTPS request
- Optional access logging and lifecycle rules

## Usage

```hcl
module "artifacts" {
  source = "github.com/sohailriyas01/terraform-template//modules/s3-bucket"

  bucket = "acme-build-artifacts"

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
    Team = "platform"
  }
}
```

With a customer-managed KMS key:

```hcl
module "secure" {
  source = "github.com/sohailriyas01/terraform-template//modules/s3-bucket"

  bucket      = "acme-sensitive"
  kms_key_arn = aws_kms_key.s3.arn
}
```

A runnable example is in [`examples/complete`](./examples/complete).

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `bucket` | Globally unique bucket name | — |
| `versioning` | Enable object versioning | `true` |
| `force_destroy` | Let Terraform delete a non-empty bucket | `false` |
| `kms_key_arn` | KMS key for SSE-KMS; SSE-S3 if unset | `null` |
| `bucket_key_enabled` | S3 bucket key to reduce KMS costs | `true` |
| `enable_tls_enforcement` | Deny non-HTTPS requests via bucket policy | `true` |
| `logging_target_bucket` | Bucket for server access logs | `null` |
| `logging_target_prefix` | Prefix for delivered logs | `null` |
| `lifecycle_rules` | List of lifecycle rules (see below) | `[]` |
| `tags` | Tags for the bucket | `{}` |

### Lifecycle rule fields

Each entry in `lifecycle_rules` takes an `id` plus any of: `enabled`, `prefix`,
`abort_incomplete_multipart_days`, `expiration_days`,
`noncurrent_version_expiration_days`, `transitions`, and
`noncurrent_version_transitions`. The `transitions` lists take `{ days, storage_class }`.

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | Bucket name |
| `bucket_arn` | Bucket ARN |
| `bucket_domain_name` | Bucket domain name |
| `bucket_regional_domain_name` | Region-specific domain name |
| `hosted_zone_id` | Route 53 zone ID for alias records |

## Notes

- The bucket is private. To grant access, attach IAM policies to the consuming principals
  using `bucket_arn` rather than loosening the bucket itself.
- Noncurrent-version lifecycle rules only do anything while `versioning = true`.
- `force_destroy` defaults to `false` so a `terraform destroy` won't silently wipe data;
  set it `true` only for throwaway buckets.
