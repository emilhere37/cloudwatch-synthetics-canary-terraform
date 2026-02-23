# main.tf (Root)

provider "aws" {
  region = var.aws_region
}

# 1. Deploy the Shared Infrastructure (VPC Endpoints, S3, IAM)
module "canary_infra" {
  source     = "./modules/canary-infra"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
}

# 2. Deploy the Canary 
module "canary" {
  source = "./modules/canary"

  # Inputs
  name            = var.name
  runtime_version = var.runtime_version
  frequency       = var.frequency
  api_hostname    = var.api_hostname
  api_path        = var.api_path
  take_screenshot = var.take_screenshot
  alert_sns_topic = var.alert_sns_topic
  
  reports_bucket    = module.canary_infra.reports_bucket 
  role_arn          = module.canary_infra.role_arn
  security_group_id = module.canary_infra.security_group
  subnet_ids        = var.subnet_ids
}