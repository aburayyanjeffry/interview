# Set AWS as the Cloud Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Set AWS region
provider "aws" {
  region = "ap-southeast-1"
}

# Set the default VPC as the VPC
resource "aws_default_vpc" "main" {
  tags = {
    Name = "Default VPC"
  }
}

# Set AWS security group to allow SSH and HTTP
resource "aws_security_group" "ssh_http" {
  name        = "ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_default_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # make this your IP/IP Range
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


# AWS EC2 configuration. The user_data contains the script to install Nginx
resource "aws_instance" "app_server" {
  ami           = "ami-029562ad87fe1185c"
  instance_type = "t2.micro"
  key_name = "kaptenjeffry"
  vpc_security_group_ids = [aws_security_group.ssh_http.id]
  user_data = <<EOF
   #!/bin/bash
   sudo apt update
   sudo apt install nginx
   sudo systemctl start nginx
  EOF

  tags = {
    Name = "Nginx at Ubuntu by Terraform"
  }
}

# EC2 Public IP
output "app_server_public_ip" {
  description = "Public IP address of app_server"
  value       = aws_instance.app_server.public_ip
}
