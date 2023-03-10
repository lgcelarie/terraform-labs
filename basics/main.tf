terraform {
  backend "remote" {
    organization = "lgcelarie"
    hostname = "app.terraform.io"

    workspaces {
      name = "terraform-testing"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

locals {
  project_name = "Celarie"
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "my-vpc2"
#   cidr = "11.0.0.0/16"

#   providers = {
#     aws = aws.eu
#    }

#   azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#   private_subnets = ["11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
#   public_subnets  = ["11.0.101.0/24", "11.0.102.0/24", "11.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

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
  ami                         = "ami-0b5eea76982371e91"
  # provider = aws.eu
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.terraform_subnet.id
  # subnet_id = module.vpc.private_subnets[0]

#   network_interface {
#     network_interface_id = aws_network_interface.my_instance_eni.id
#     device_index         = 0
#   }

  tags = {
    Name = "HelloWorld - ${local.project_name}"
  }
}
