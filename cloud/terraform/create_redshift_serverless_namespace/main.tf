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

resource "aws_redshiftserverless_namespace" "e_commerce_namespace" {
  namespace_name = "e-commerce-sales"
  region = "us-east-1"
  admin_username = "your-usernam"
  admin_user_password = "your-password"
  default_iam_role_arn = "arn:aws:iam::xxxxxxxxxxxx:role/your-IAM"
  db_name = "dev"
  iam_roles = ["arn:aws:iam::xxxxxxxxxxxx:role/your-IAM"]
}