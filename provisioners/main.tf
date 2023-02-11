terraform {
  # backend "remote" {
  #   organization = "lgcelarie"
  #   hostname = "app.terraform.io"

  #   workspaces {
  #     name = "provisioners-wp"
  #   }
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

# data "template_file" "user_data" {
#     template = file("./userdata.yaml")
# }

resource "aws_security_group" "allow_http_myserver" {
  name        = "allow_http_myserver"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "SSH from Host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["190.86.33.128/32"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_internet_gateway" "terraform_gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "TerraformInternetGateway"
  }
}

resource "aws_route" "terraform_def_route" {
  route_table_id         = aws_vpc.terraform_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terraform_gw.id
}

resource "aws_instance" "my_instance" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.terraform_subnet.id
  key_name                    = aws_key_pair.my_instance_key.key_name
  security_groups             = [aws_security_group.allow_http_myserver.id]
  user_data                   = file("./userdata.yaml")

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
    ]
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.private_ip
      # private_key = file("file loecation")
    }
  }

  provisioner "file" {
    content     = "./test_file"
    destination = "/tmp/file.log"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.private_ip
      # private_key = file("file loecation")
    }
  }

  depends_on = [
    aws_internet_gateway.terraform_gw
  ]

  tags = {
    Name = "ProvisionersInstance"
  }
}

resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-pok --instance-ids ${aws_instance.my_instance.id}"
  }

  depends_on = [
    aws_instance.my_instance
  ]
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}