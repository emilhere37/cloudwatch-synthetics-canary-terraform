# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs in which to execute the canary"
}
