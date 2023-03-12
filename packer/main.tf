terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
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

data "aws_ami" "packer_ami" {
  executable_users = ["self"]
  most_recent      = true
  filter {
    name   = "name"
    values = ["using-packer"]
  }
  owners = ["self"]
}

resource "aws_instance" "my_instance" {
  #ami                         = "ami-0b5eea76982371e91"
  # provider = aws.eu
  ami                         = data.aws_ami.packer_ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id
  # subnet_id = module.vpc.private_subnets[0]

  #   network_interface {
  #     network_interface_id = aws_network_interface.my_instance_eni.id
  #     device_index         = 0
  #   }

  tags = {
    Name = "HelloWorld - with packer"
  }
}
