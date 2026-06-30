data "aws_cloudfront_cache_policy" "this" {
  name = var.cache_policy_name
}

locals {
  is_s3        = var.origin_type == "s3"
  use_acm_cert = var.acm_certificate_arn != null
}

# Origin Access Control lets CloudFront reach a private S3 bucket without making it public.
resource "aws_cloudfront_origin_access_control" "this" {
  count = local.is_s3 ? 1 : 0

  name                              = "${var.name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.web_acl_id

  origin {
    origin_id                = "primary"
    domain_name              = var.origin_domain_name
    origin_access_control_id = local.is_s3 ? aws_cloudfront_origin_access_control.this[0].id : null

    dynamic "custom_origin_config" {
      for_each = local.is_s3 ? [] : [1]
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.origin_protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    target_origin_id         = "primary"
    viewer_protocol_policy   = var.viewer_protocol_policy
    allowed_methods          = var.allowed_methods
    cached_methods           = var.cached_methods
    compress                 = true
    cache_policy_id          = data.aws_cloudfront_cache_policy.this.id
    origin_request_policy_id = var.origin_request_policy_id
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !local.use_acm_cert
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = local.use_acm_cert ? "sni-only" : null
    minimum_protocol_version       = local.use_acm_cert ? "TLSv1.2_2021" : null
  }

  dynamic "logging_config" {
    for_each = var.logging_bucket != null ? [1] : []
    content {
      bucket          = var.logging_bucket
      prefix          = var.logging_prefix
      include_cookies = false
    }
  }

  tags = var.tags
}
