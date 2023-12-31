# Store terraform state in GCP bucket
terraform {
  backend "gcs" {
    bucket = "moose-hunters-mineservu-bucket-tfstate"
    prefix = "terraform/state"
  }
}

# Bucket for terraform state file
resource "google_storage_bucket" "default" {
  name                        = var.tf_state_bucket_name
  force_destroy               = false
  location                    = var.tf_state_bucket_location
  storage_class               = "STANDARD"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}