provider "aws" {
  # Configuration options
  # profile = "default"
  region  = "us-east-1"
}

provider "aws" {
  region = "eu-west-1"
  # profile = "default"
  alias = "eu"
}
