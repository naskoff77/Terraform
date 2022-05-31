# Main var for the module, either "dev" or "www" but in the future can also be "qa","stg", etc
variable "env" {
  type        = string
  description = "Environment name which everything is based off of"
}

# only supports one primary DNS zone atm, so this value must be input at deployment
variable "zone_id" {
  type = string
  description = "zone ID to deploy DNS into for the site"
}