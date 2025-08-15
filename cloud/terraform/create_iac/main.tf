terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  region     = var.bucket_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "bucket" {
  bucket = "e-commerce-sales-bucket"

  tags = {
    Name        = "test-1"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "staging_bucket" {
  bucket = "e-commerce-sales-staging"

  tags = {
    Name        = "staging"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "object_shopee_dev" {
  for_each = fileset("../../data/shopee/clean/dev/", "*.csv")
  bucket = "e-commerce-sales-bucket"
  key    = "/data/shopee/clean/dev/${each.value}"
  source = "../../data/shopee/clean/dev/${each.value}"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "object_shopee_prod" {
  for_each = fileset("../../data/shopee/clean/prod/", "*.csv")
  bucket = "e-commerce-sales-bucket"
  key    = "/data/shopee/clean/prod/${each.value}"
  source = "../../data/shopee/clean/prod/${each.value}"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "kit_components_dev" {
  bucket = "e-commerce-sales-bucket"
  key    = "/data/supplies/clean/spectrum_kit_dev/dev_kit_components.csv"
  source = "../../data/supplies/clean/dev_kit_components.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "kit_components_prod" {
  bucket = "e-commerce-sales-bucket"
  key    = "/data/supplies/clean/spectrum_kit_prod/kit_components.csv"
  source = "../../data/supplies/clean/kit_components.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "costs_dev" {
  bucket = "e-commerce-sales-bucket"
  key    = "/data/supplies/clean/spectrum_costs_dev/dev_clean_cost.csv"
  source = "../../data/supplies/clean/dev_clean_cost.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

resource "aws_s3_object" "costs_prod" {
  bucket = "e-commerce-sales-bucket"
  key    = "/data/supplies/clean/spectrum_costs_prod/clean_cost_data.csv"
  source = "../../data/supplies/clean/clean_cost_data.csv"
  depends_on = [ aws_s3_bucket.bucket ]
}

data "aws_vpc" "default_vpc" {
  id = var.aws_vpc
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-instance-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default_vpc.id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name        
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = {
    Name = "test"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install python3-pip -y
              pip3 install boto3 pandas pyarrow dbt-core dbt-redshift redshift_connector
              EOF
  
  iam_instance_profile = "EC2-SSM-Redshift-Access"

}

resource "null_resource" "copy_folder" {
  depends_on = [aws_instance.this]
  
  connection {
    type        = "ssh"
    host        = aws_instance.this.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/ec2-instance.pem")
  }

  # Copy entire folder recursively
  provisioner "file" {
    source      = "C:/Users/nicol/OneDrive/Área de Trabalho/e-commerce-sales-pipeline/cloud/scripts"          # Local folder (contents copied)
    destination = "/home/ec2-user/" # Remote folder (must exist)
  }

    # Copy entire folder recursively
  provisioner "file" {
    source      = "C:/Users/nicol/OneDrive/Área de Trabalho/e-commerce-sales-pipeline/cloud/dbt_files"          # Local folder (contents copied)
    destination = "/home/ec2-user/" # Remote folder (must exist)
  }

  # Optional: Set permissions afterward
  provisioner "remote-exec" {
    inline = [
      "chmod -R +x /home/ec2-user/scripts/"  # Make scripts executable
    ]
  }
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value = aws_instance.this.public_ip
}

output "ec2_security_group_id" {
  description = "EC2 instance security group ID"
  value       = aws_instance.this.vpc_security_group_ids
}

resource "aws_redshiftserverless_namespace" "e_commerce_namespace" {
  namespace_name = var.namespace_name
  region = var.redshift_region
  admin_username = var.admin_username
  admin_user_password = var.admin_user_password
  default_iam_role_arn = var.default_iam_role_arn
  db_name = var.initial_db
  iam_roles = [var.default_iam_role_arn]
  depends_on = [ aws_instance.this ]
}

resource "aws_redshiftserverless_workgroup" "sales_workgroup" {
  namespace_name = var.namespace_name
  workgroup_name = var.workgroup_name
  region = var.redshift_region
  base_capacity = var.base_capacity
  port = var.redshift_port
  depends_on = [ aws_redshiftserverless_namespace.e_commerce_namespace]
}

resource "aws_security_group_rule" "ec2_to_redshift" {
  region            = var.ec2_region
  from_port         = var.ec2_port
  protocol          = var.protocol
  security_group_id = var.default_sg
  to_port           = var.redshift_port
  type              = "ingress"
  source_security_group_id = aws_security_group.ec2_sg.id
  depends_on = [ aws_redshiftserverless_workgroup.sales_workgroup ]
}