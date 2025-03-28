variable "account_id" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "namespace" {
  type    = string
  default = "api-ping"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  common_tags = {
    ProvisionedBy = "terraform"
  }
}
