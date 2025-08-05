terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  region     ="us-east-1"
  access_key = "your-access-key"
  secret_key = "your-secret-key"
}

data "aws_vpc" "default_vpc" {
  id = "your-vpc-id"
}

resource "aws_redshiftserverless_workgroup" "test" {
  namespace_name = "e-commerce-sales"
  workgroup_name = "e-commerce-sales"
  region = "us-east-1"
  base_capacity = 4
  port = 5439
}