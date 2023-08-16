resource "random_id" "default" {
  byte_length = 8
}

# Storage bucket for cloud function source codes
resource "google_storage_bucket" "gcf" {
  name                        = "${random_id.default.hex}-minecraftserver-gcf-source"
  location                    = var.cloudfunctions_bucket_location
  uniform_bucket_level_access = true
}

# Data values for function source codes
data "archive_file" "default_start" {
  type        = "zip"
  output_path = "./gcp-functions/start-stop-minecraft-server.zip"
  source_dir  = "gcp-functions"
}

# Add source codes to bucket
resource "google_storage_bucket_object" "object_start_stop" {
  name   = "start-stop-minecraft-server.zip"
  bucket = google_storage_bucket.gcf.name
  source = data.archive_file.default_start.output_path
}

# Cloud function to start the minecraft server
resource "google_cloudfunctions2_function" "default_start" {
  name        = "function-start-minecraft-server"
  location    = var.mineservu_region
  description = "Start minecraft server"

  build_config {
    runtime     = "nodejs20"
    entry_point = "startInstance"
    source {
      storage_source {
        bucket = google_storage_bucket.gcf.name
        object = google_storage_bucket_object.object_start_stop.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 240
  }
}

# Make the start server function public
resource "google_cloud_run_service_iam_binding" "invoker_start" {
  project  = google_cloudfunctions2_function.default_start.project
  location = google_cloudfunctions2_function.default_start.location
  service  = google_cloudfunctions2_function.default_start.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}

# Cloud function to stop the server
resource "google_cloudfunctions2_function" "default_stop" {
  name        = "function-stop-minecraft-server"
  location    = var.mineservu_region
  description = "Stop minecraft server"

  build_config {
    runtime     = "nodejs20"
    entry_point = "stopInstance"
    source {
      storage_source {
        bucket = google_storage_bucket.gcf.name
        object = google_storage_bucket_object.object_start_stop.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 240
  }
}

# Make the stop server function public
resource "google_cloud_run_service_iam_binding" "invoker_stop" {
  project  = google_cloudfunctions2_function.default_stop.project
  location = google_cloudfunctions2_function.default_stop.location
  service  = google_cloudfunctions2_function.default_stop.name

  role    = "roles/run.invoker"
  members = ["allUsers"]
}