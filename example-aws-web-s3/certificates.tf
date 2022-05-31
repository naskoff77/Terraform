# Certificate for cloudfront distribution for web s3
resource "aws_acm_certificate" "web_s3_cf_certificate" {
  domain_name       = "${var.env}.exampledomain.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "${var.env}.exampledomain.com"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# automatic validation of the certificate (requires route53 record to be created in route53.tf - this works sometimes)
resource "aws_acm_certificate_validation" "web_s3_cf_certificate_validation" {
  certificate_arn         = aws_acm_certificate.web_s3_cf_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.web_s3_acm_cf_validation_record : record.fqdn]
}