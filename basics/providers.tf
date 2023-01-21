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
