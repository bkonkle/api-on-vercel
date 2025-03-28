
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "${var.namespace}-${var.region}-tf-state"
    dynamodb_table = "${var.namespace}-tf-locks"
    key            = "env/${var.environment}/terraform.tfstate"
    region         = var.region
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "service" {
  source = "../modules/service"

  account_id  = local.account_id
  namespace   = var.namespace
  region      = var.region
  environment = var.environment
}
