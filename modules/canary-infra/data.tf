# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_region" "current" {}

data "aws_route_table" "selected" {
  subnet_id = var.subnet_ids[0]
}
