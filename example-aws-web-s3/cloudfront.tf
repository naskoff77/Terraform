# Cloudfront distribution settings
resource "aws_cloudfront_distribution" "web_s3_cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_s3_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.web_s3_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_s3_cloudfront_origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases = [
    aws_acm_certificate.web_s3_cf_certificate.domain_name
  ]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "web s3 cloudfront distribution"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.web_s3_bucket.id}.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  web_acl_id = aws_wafv2_web_acl.web_s3_wafv2_web_acl.arn

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.web_s3_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = [
        "US"
      ]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.web_s3_cf_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  depends_on = [aws_acm_certificate.web_s3_cf_certificate]
}

resource "aws_cloudfront_origin_access_identity" "web_s3_cloudfront_origin_access_identity" {
  comment = "web s3 OAI to access bucket"
}

# WAF configuration
resource "aws_wafv2_web_acl" "web_s3_wafv2_web_acl" {
  name        = "${var.env}-wafv2-acl"
  description = "wafv2 web acl for ${var.env}.sierracloudconsulting.com"

  scope = "CLOUDFRONT"
  default_action {
    allow {}
  }

  rule {
    name     = "primary_rule"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }

        scope_down_statement {
          geo_match_statement {
            country_codes = [
              "US"
            ]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.env}-cf-site-cw-metric"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.env}-cf-site-cw-metric"
    sampled_requests_enabled   = false
  }
}