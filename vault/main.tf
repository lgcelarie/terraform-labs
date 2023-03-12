terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.13.0"
    }
  }
}

provider "aws" {
  region     = data.vault_generic_secret.aws_creds.data["region"]
  access_key = data.vault_generic_secret.aws_creds.data["aws_access_key"]
  secret_key = data.vault_generic_secret.aws_creds.data["aws_secret_access_key"]
}

data "vault_generic_secret" "aws_creds" {
  path = "secret/aws"
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TerraformVPC"
  }
}