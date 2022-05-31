# ses configuration
resource "aws_ses_domain_identity" "web_s3_contact_domain_identity" {
  domain = "exampledomain.com"
}

resource "aws_ses_configuration_set" "web_s3_contact_config_set" {
  name = "${var.env}-web-s3-ses-config-set"
}

resource "aws_ses_domain_mail_from" "web_s3_contact_domain_mail_from" {
  domain           = aws_ses_domain_identity.web_s3_contact_domain_identity.domain
  mail_from_domain = "customercontact.${aws_ses_domain_identity.web_s3_contact_domain_identity.domain}"
}

resource "aws_ses_email_identity" "web_s3_email_identity" {
  email = local.web_s3_email_identity
}

data "aws_iam_policy_document" "web_s3_ses_contact_policy_document" {
  statement {
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]
    resources = [
      aws_ses_domain_identity.web_s3_contact_domain_identity.arn
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_ses_identity_policy" "web_s3_ses_contact_identity_policy" {
  identity = aws_ses_domain_identity.web_s3_contact_domain_identity.arn
  name     = "${var.env}-ses-contact-identity-policy"
  policy   = data.aws_iam_policy_document.web_s3_ses_contact_policy_document.json
}