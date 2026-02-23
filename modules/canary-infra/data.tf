#modules/canary-infra/data.tf

data "aws_region" "current" {}

data "aws_route_table" "selected" {
  subnet_id = var.subnet_ids[0]
}