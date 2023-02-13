terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.52.0"
    }
  }
}

provider "google" {
 zone = "us-central1-c"
 region = "us-central1"
 credentials = "appid.json"
 project = "idgoeshere"
}