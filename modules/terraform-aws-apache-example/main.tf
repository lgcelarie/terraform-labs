
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
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id

  tags = {
    Name = "Server-ApacheTF"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description     = "HTTP access"
      from_port       = 80
      to_port         = 80
      protocol        = "HTTP"
      cidr_blocks     = [var.access_ip]
      security_groups = []
      prefix_list_ids = []
      self            = false
  }
  ingress {
    description     = "HTTPS access"
      from_port       = 443
      to_port         = 443
      protocol        = "HTTPS"
      cidr_blocks     = [var.access_ip]
      security_groups = []
      prefix_list_ids = []
      self            = false
  }
  ingress {
    description     = "SSL access"
      from_port       = 22
      to_port         = 22
      protocol        = "SSH"
      cidr_blocks     = [var.access_ip]
      security_groups = []
      prefix_list_ids = []
      self            = false
  }

  egress {
    description = "outgoing for everyone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.my_instance[1].public_ip
}