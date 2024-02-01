########################################
# Terraform for AWS
########################################
variable "workspace_iam_roles" {
  default = {
    development = "arn:aws:iam::668479700230:role/rws-dev-role-terraform"
  }
}

provider "aws" {
  assume_role {
      role_arn = "${var.workspace_iam_roles[terraform.workspace]}"
    }  
  region  = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "rws-terraform-state"
    key    = "tfstate/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt        	   = true
    dynamodb_table = "rws-terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }

  }

  required_version = ">= 0.15"
}
