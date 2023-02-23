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

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-tf-celarie-bucket"
  depends_on = [
    aws_instance.my_instance
  ]
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

resource "aws_instance" "my_instance" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id

  tags = {
    Name = "HelloWorld - Project"
  }
}


output "public_ip" {
  value = aws_instance.my_instance.public_ip
}