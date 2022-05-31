# currently supports a "dev" site and "www" site
locals {
  web_s3_email_identity = var.env == "dev" ? "dev.customercontact@exampledomain.com" : "customercontact@exampledomain.com"
}