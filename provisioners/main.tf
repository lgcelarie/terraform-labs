terraform {
  backend "remote" {
    organization = "lgcelarie"
    hostname = "app.terraform.io"

    workspaces {
      name = "provisioners-wp"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

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

resource "aws_key_pair" "my_instance_key" {
  key_name   = "my-instance-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDO+OiRBjQ50EDpP1u5yQsz4UJb31/reDpZw5Rm68XB9o0C2eUHSB+VfYV++YhEkea/M8BtQ3wUVgCEESU3Eep9SY6YCso33yXLrqOkpAHWdoHQYJBAJwsF8xBwwF1/U7I2ykpUwLQm9LgU4Irgk3Tl8cwNqCNJ2AmnADSQ9Imb+1Nm71KKgJTHR3GCnQ+70OtP1GAf2r56F8+WA1vtiS8flXVR4ZVUa2hmJ5uFuBB6h39ktrnXrfU2Kgvrkw0mprxjjtdo3ndhJa/cWthbnyLUYXtMH8XAbDAjHWBcVKo037P9BfqwexVdUcpyMNvPrbJx0IuOpR9QQPVWK5ke4ijjfBwaHsOw5pLio+/05+SPMnqDtgymJFBiJQCggoXaLA23aXAZ3q3DM4Qj/2rU2Kiuh4xOQewhtRlXzhR28EQoWQ4Fsw/YbjHNs7QxBCmICMbAvb+DM7PQeaMpRrog19OQu7vTOYFm9+Zshegq2rVWl4rYxWO+k738yy48HIHB7k="
}

resource "aws_instance" "my_instance" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.mmicro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.terraform_subnet.id
  key_name = aws_key_pair.my_instance_key.key_name

  tags = {
    Name = "ProvisionersInstance"
  }
}