include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  env = local.env_vars.locals.aws_env
}

terraform {
  source = "git::https://github.com/birkoff/terraform-aws-cloudfront-s3-website-fe.git//"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=60m"]
  }
}

inputs = {
  comment          = "API Docs for JunctionNet Platform"
  bucket_region    = local.env_vars.locals.region
  hosted_zone_name = "junctionnet.cloud"
  logs_bucket      = "production-platform-apps-factory-logs"
  logs_prefix      = "CloudFront/API_docs"
  merge_hosted_zone_name = false
  frontend_subdomain_aliases = [
    "api-docs",
  ]
}
