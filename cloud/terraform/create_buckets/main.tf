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

resource "aws_s3_bucket" "test" {
  bucket = "test-aws"

  tags = {
    Name        = "test-1"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object_shopee_dev" {
  for_each = fileset("../extraction/data/shopee/clean/dev/", "*.csv")
  bucket = "e-commerce-sales-bucket"
  key    = "/data/shopee/clean/dev/${each.value}"
  source = "../extraction/data/shopee/clean/dev/${each.value}"
}

resource "aws_s3_object" "object_shopee_prod" {
  for_each = fileset("../extraction/data/shopee/clean/prod/", "*.csv")
  bucket = "e-commerce-sales-bucket"
  key    = "/data/shopee/clean/prod/${each.value}"
  source = "../extraction/data/shopee/clean/prod/${each.value}"
}
