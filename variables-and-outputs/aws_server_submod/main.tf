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
  region  = "us-east-2"
}

variable "instance_type" {
  type        = string
  description = "Type of instance for the EC2 resource."
  validation {
    condition     = can(regex("^t2.", var.instance_type))
    error_message = "The type value must be a valid EC2 t2 size."
  }
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
  ami = "ami-0b5eea76982371e91"
  # provider = aws.eu
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id
  # subnet_id = module.vpc.private_subnets[0]

  #   network_interface {
  #     network_interface_id = aws_network_interface.my_instance_eni.id
  #     device_index         = 0
  #   }

  tags = {
    Name = "HelloWorld - ${local.project_name}"
  }
}

output "public_ip" {
  value = aws_instance.my_instance.public_ip
}