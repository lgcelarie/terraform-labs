terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

locals {
  ingress = [{
    port        = 443
    description = "Port 443"
    protocol = "tcp" },
    {
      port        = 80
      description = "Port 80"
    protocol = "tcp" }
  ]
}
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TerraformVPC"
  }
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "11.0.0.0/24"

  tags = {
    Name = "TerraformSubnet"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  dynamic "ingress" {
    for_each = local.ingress
    content {
      description     = ingress.value.description
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.protocol
      cidr_blocks     = [aws_vpc.terraform_vpc.cidr_block]
      security_groups = []
      prefix_list_ids = []
      self            = false
    }
  }
  ingress {

  }

  egress {
    description = "outgoing for everyone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}