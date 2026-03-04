# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "archive_file" "canary_zip" {
  type        = "zip"
  source_dir = "${path.module}/src" 
  output_path = "${path.module}/canary_package.zip"
}

resource "aws_synthetics_canary" "canary" {
  name                 = var.name
  artifact_s3_location = "s3://${var.reports_bucket}/"
  execution_role_arn   = var.role_arn
  handler              = "canary.handler"
  zip_file             = data.archive_file.canary_zip.output_path
  runtime_version      = var.runtime_version
  start_canary         = true

  schedule {
    expression = "rate(${var.frequency} minutes)"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  run_config {
    timeout_in_seconds = 60
    
    
    environment_variables = {
      API_HOSTNAME = var.api_hostname
      API_PATH     = var.api_path
    }
  }
  
  depends_on = [data.archive_file.canary_zip]
}
