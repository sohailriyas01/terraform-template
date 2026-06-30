# cloudfront

A CloudFront distribution for either a private S3 origin (via Origin Access Control) or a
custom HTTP origin like an ALB. HTTPS is enforced by default, it attaches a managed cache
policy, and it supports alternate domains with an ACM certificate and SPA-style error
handling.

## Usage

In front of a private S3 bucket:

```hcl
module "cdn" {
  source = "github.com/sohailriyas01/terraform-template//modules/cloudfront"

  name               = "site"
  origin_type        = "s3"
  origin_domain_name = aws_s3_bucket.site.bucket_regional_domain_name

  aliases             = ["www.example.com"]
  acm_certificate_arn = aws_acm_certificate.site.arn # must be in us-east-1
}
```

The S3 bucket policy must allow this distribution. Grant `s3:GetObject` to the
`cloudfront.amazonaws.com` service principal, conditioned on
`AWS:SourceArn = module.cdn.distribution_arn` — see [`examples/complete`](./examples/complete).

In front of a custom origin (e.g. an ALB):

```hcl
module "cdn" {
  source = "github.com/sohailriyas01/terraform-template//modules/cloudfront"

  name               = "api"
  origin_type        = "custom"
  origin_domain_name = module.service.alb_dns_name
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Resource name prefix | — |
| `comment` | Console comment | `null` |
| `origin_type` | `s3` or `custom` | `s3` |
| `origin_domain_name` | Origin host | — |
| `origin_protocol_policy` | Origin connection policy (custom origins) | `https-only` |
| `default_root_object` | Root object | `index.html` |
| `price_class` | Edge location tier | `PriceClass_100` |
| `aliases` | Alternate domain names | `[]` |
| `acm_certificate_arn` | ACM cert in us-east-1 | `null` |
| `viewer_protocol_policy` | Viewer connection policy | `redirect-to-https` |
| `allowed_methods` | Methods forwarded to origin | `["GET","HEAD","OPTIONS"]` |
| `cached_methods` | Methods cached | `["GET","HEAD"]` |
| `cache_policy_name` | Managed cache policy | `Managed-CachingOptimized` |
| `origin_request_policy_id` | Origin request policy ID | `null` |
| `custom_error_responses` | Error response mappings | `[]` |
| `geo_restriction_type` | `none`/`whitelist`/`blacklist` | `none` |
| `geo_restriction_locations` | Country codes | `[]` |
| `web_acl_id` | WAFv2 web ACL ARN | `null` |
| `logging_bucket` | Access log bucket domain name | `null` |
| `logging_prefix` | Access log prefix | `null` |
| `tags` | Tags for the distribution | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `distribution_id` | Distribution ID |
| `distribution_arn` | Distribution ARN (for the S3 bucket policy condition) |
| `domain_name` | CloudFront domain name |
| `hosted_zone_id` | Hosted zone ID for Route 53 alias records |
| `origin_access_control_id` | OAC ID (null for custom origins) |

## Notes

- For aliases, the ACM certificate **must** be in `us-east-1` — CloudFront only reads certs
  from that region regardless of where the rest of your stack lives.
- For a single-page app, map `403` and `404` to `/index.html` with response code `200` via
  `custom_error_responses` so client-side routing works.
- The default behavior uses the managed `CachingOptimized` policy. For dynamic origins that
  need cookies/headers/query strings forwarded, set a different `cache_policy_name` and an
  `origin_request_policy_id`.
