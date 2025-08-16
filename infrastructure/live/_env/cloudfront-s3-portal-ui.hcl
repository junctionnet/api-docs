locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  env = local.env_vars.locals.env
}

terraform {
  source = "../../../modules//frontend"
}

inputs = {
  comment          = "FE UI Portal"
  bucket_region    = local.env_vars.locals.region
  hosted_zone_name = local.env_vars.locals.hosted_zone_name
  logs_bucket      = local.env_vars.locals.logs_bucket
  logs_prefix      = "CloudFront/${local.env}"
  frontend_subdomain_aliases = [
    "api-docs",
  ]
}
