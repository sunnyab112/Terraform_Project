#AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}

# configure the aws provider
provider "aws" {
  region = "us-west-2"
}