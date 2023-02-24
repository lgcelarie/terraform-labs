terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
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

resource "aws_instance" "my_instance" {
  for_each = {
    nano  = "t2.nano"
    micro = "t2.micro"
    small = "t2.small"
  }
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = each.value
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id

  tags = {
    Name = "Server-${each.key}"
  }
}


output "public_ip" {
  value = values(aws_instance.my_instance)[*].public_ip
}