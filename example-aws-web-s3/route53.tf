# DNS record to point to CF distribution
resource "aws_route53_record" "web_s3_route53_record" {
  zone_id = "${var.zone_id}"
  name    = "${var.env}.exampledomain.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_s3_cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.web_s3_cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# DNS record to validate SES domain identity
resource "aws_route53_record" "web_s3_contact_domain_identity_record" {
  zone_id = "${var.zone_id}"
  name    = "_amazonses.${var.env}.exampledomain.com"
  type    = "TXT"
  ttl     = "600"
  records = [
    aws_ses_domain_identity.web_s3_contact_domain_identity.verification_token
  ]
}

# DNS record to validate ACM Certificate
resource "aws_route53_record" "web_s3_acm_cf_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.web_s3_cf_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = "${var.zone_id}"
}