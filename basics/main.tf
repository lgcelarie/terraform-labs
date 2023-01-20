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

provider "aws" {
  region = "eu-west-1"
  profile = "default"
  alias = "eu"
}

variable "instance_type" {
  type = string

}

locals {
  project_name = "Celarie"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc2"
  cidr = "11.0.0.0/16"

  providers = {
    aws = aws.eu
   }

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["11.0.1.0/24", "11.0.2.0/24", "11.0.3.0/24"]
  public_subnets  = ["11.0.101.0/24", "11.0.102.0/24", "11.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
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
  ami                         = "ami-0fe0b2cf0e1f25c8a"
  provider = aws.eu
  instance_type               = var.instance_type
  associate_public_ip_address = true
  # subnet_id = aws_subnet.terraform_subnet.id
  subnet_id = module.vpc.private_subnets[0]

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
