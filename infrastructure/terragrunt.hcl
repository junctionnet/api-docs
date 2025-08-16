locals {
  # ENV
  env_regex = "infrastructure/live/([a-zA-Z0-9-]+)/"
  aws_env = try(regex(local.env_regex, get_original_terragrunt_dir())[0])
####   terragrunt_dir = get_terragrunt_dir()
  terragrunt_dir = path_relative_to_include()
  main_public_dns_zone_name = "junctionnet.cloud"
  account_mapping = {
    dev             = 225725557140
    shared-services = 551892827149
    production      = 894898254520
  }
  account_role_name     = "terraform-role"
  multiaccount_role_arn = "arn:aws:iam::551892827149:role/terraform-multiaccount-role" # shared-services

  # Split the path into a list of directories
  dir_parts = split("/", local.terragrunt_dir)

  region = "us-west-1"

  # Application
  application  = "ApiDocs"
  service = "swagger-ui"

  # Skip the first three parts and join the remaining parts to form the directory name
  # Fix this JNET-1201
  # component = join("/", slice(local.dir_parts, 3, length(local.dir_parts)))
  component = join("/", slice(local.dir_parts, 1, length(local.dir_parts)))
  # region will always be the second element (after env)
  # e.g. dev/us-east-1/... → ["dev","us-east-1",...]
  aws_region = local.dir_parts[1]
}


iam_role = local.multiaccount_role_arn


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "junction-apps-factory-terraform-state"
    key            = "${local.application}/${local.service}/${local.aws_env}/${local.component}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "junction-apps-factory-platform-terraform-lock-table"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region}"
      allowed_account_ids = [
        "${local.account_mapping[local.aws_env]}"
      ]
      assume_role {
        role_arn = "arn:aws:iam::${local.account_mapping[local.aws_env]}:role/${local.account_role_name}"
      }
      default_tags {
        tags = {
          Environment = "${local.aws_env}"
          ManagedBy   = "terraform"
          DeployedBy  = "terragrunt"
          Creator     = "${get_env("USER", "NOT_SET")}"
          Application = "${local.application}"
          Service = "${local.service}"
          Component   = "${local.component}"
        }
      }
    }
EOF
}
