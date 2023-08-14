terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.mineservu_project_id
  region  = var.mineservu_region
  zone    = var.mineservu_zone
}