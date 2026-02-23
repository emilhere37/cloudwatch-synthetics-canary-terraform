#modules/canary-infra/variable.tf

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs in which to execute the canary"
}