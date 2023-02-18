terraform {
}

module "aws_server_submod" {
  source        = ".//aws_server_submod"
  instance_type = "t2.micro"
}

output "instance_ip" {
  value = module.aws_server_submod.public_ip
}