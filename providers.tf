terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }

  backend "s3" {
    bucket  = "acer-tf"
    key     = "state/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}