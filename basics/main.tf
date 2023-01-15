terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "default"
  region  = "us-east-1"
}

variable "instance_type" {
  type = string

}

locals {
  project_name = "Celarie"
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

resource "aws_network_interface" "my_instance_eni" {
  subnet_id   = aws_subnet.terraform_subnet.id
  private_ips = ["11.0.0.10"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "my_instance" {
  ami                         = "ami-06878d265978313ca"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.terraform_subnet.id

#   network_interface {
#     network_interface_id = aws_network_interface.my_instance_eni.id
#     device_index         = 0
#   }

  tags = {
    Name = "HelloWorld - ${local.project_name}"
  }
}

output "instance_public_ip_address" {
  value = aws_instance.my_instance.public_ip
}

output "instance_private_ip_address" {
  value = aws_instance.my_instance.private_ip
}
