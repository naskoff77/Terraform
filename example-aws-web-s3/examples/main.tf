provider "aws" {
    region = "us-east-1"
    assume_role {
        role_arn = "arn:aws:iam::ACCOUNT_ID_HERE:role/ROLE_NAME_HERE"
    }
}

module "example-web-s3-mod" {
    source = "../"

    env = "ENV_NAME_HERE"
    zone_id = "PLACE_HOLDER_ID"
}