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

# EC2 instance with security group attached
resource "aws_instance" "this" {
  ami                    = "ami-08a6efd148b1f7504"
  instance_type          = "t2.micro"
  key_name               = "ec2-instance"           
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  tags = {
    Name = "test"
  }
}

output "instance_public_ip" {
  value = aws_instance.this.public_ip
}