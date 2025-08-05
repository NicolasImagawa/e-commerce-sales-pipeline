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

resource "aws_security_group_rule" "example" {
  region            = "us-east-1"
  from_port         = 5439
  protocol          = "tcp"
  security_group_id = "redshift-security-group-id"
  to_port           = 5439
  type              = "ingress"
  source_security_group_id = "ec2-security-group-id"
}
