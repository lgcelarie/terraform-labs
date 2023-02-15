terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.52.0"
    }
  }
}

provider "google" {
  zone        = "us-central1-c"
  region      = "us-central1"
  credentials = "appid.json"
  project     = "idgoeshere"
}

resource "google_compute_instance" "compute_test" {
  name         = "test"
  machine_type = "e2-medium"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }


  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}