terraform {
  backend "s3" {
    bucket = "terraform-backend-celarie"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}