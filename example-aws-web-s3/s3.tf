### All S3 bucket resources

# WEB S3 bucket resources
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "web_s3_bucket" {
  bucket        = "${var.env}-webs3-site-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "web_s3_bucket_acl" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "web_s3_iam_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.web_s3_cloudfront_origin_access_identity.iam_arn
      ]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.web_s3_bucket.arn,
      "${aws_s3_bucket.web_s3_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "web_s3_bucket_policy" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  policy = data.aws_iam_policy_document.web_s3_iam_policy_document.json
}

resource "aws_s3_bucket_versioning" "web_s3_versioning" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "web_s3_public_access_block" {
  bucket = aws_s3_bucket.web_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "web_s3_logging" {
  bucket = aws_s3_bucket.web_s3_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3/web-s3/"
}

resource "aws_s3_bucket_cors_configuration" "web_s3_cors_configuration" {
  bucket = aws_s3_bucket.web_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["${var.env}.exampledomain.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "web_s3_lifecycle_configuration" {
  bucket     = aws_s3_bucket.web_s3_bucket.bucket
  depends_on = [aws_s3_bucket_versioning.web_s3_versioning]

  rule {
    id     = "${var.env}-non-current-web-s3-versions-rule"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# Logging bucket resources
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${var.env}-webs3-logging-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "logging_bucket_iam_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.web_s3_cloudfront_origin_access_identity.iam_arn
      ]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = data.aws_iam_policy_document.logging_bucket_iam_policy_document.json
}

resource "aws_s3_bucket_versioning" "logging_bucket_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logging_bucket_public_access_block" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "logging_bucket_logging" {
  bucket = aws_s3_bucket.logging_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3/logging-bucket/"
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket_lifecycle_configuration" {
  bucket     = aws_s3_bucket.logging_bucket.bucket
  depends_on = [aws_s3_bucket_versioning.logging_bucket_versioning]

  rule {
    id     = "non-current-logging-bucket-versions-rule"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }
}

# WEB S3 code bucket resources
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "code_bucket" {
  bucket        = "${var.env}-webs3-code-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "code_bucket_acl" {
  bucket = aws_s3_bucket.code_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "code_bucket_versioning" {
  bucket = aws_s3_bucket.code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "code_bucket_public_access_block" {
  bucket = aws_s3_bucket.code_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "code_bucket_logging" {
  bucket = aws_s3_bucket.code_bucket.id

  target_bucket = aws_s3_bucket.code_bucket.id
  target_prefix = "s3/code-bucket/"
}

# zip up the lambda code from the repo
data "archive_file" "contact_lambda_code" {
  type        = "zip"
  source_dir  = "./lambda/"
  output_path = "./lambda.zip"
}

# upload zip to the s3 bucket
resource "aws_s3_object" "code_bucket_lambda_zip" {
  bucket = aws_s3_bucket.code_bucket.id
  key    = "lambda.zip"
  source = data.archive_file.contact_lambda_code.output_path
}

resource "aws_s3_bucket_lifecycle_configuration" "code_bucket_lifecycle_configuration" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  depends_on = [aws_s3_bucket_versioning.code_bucket_versioning]

  rule {
    id     = "non-current-code-bucket-versions-rule"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }
}