terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.77.0"
    }
  }
}

provider "google" {
  project = var.mineservu_project_id
  region  = var.mineservu_region
  zone    = var.mineservu_zone
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

resource "google_cloud_run_service" "run_service" {
  name = "mineservu-app"
  location = var.mineservu_region

  template {
    spec {
      containers {
        image = "${var.mineservu_region}-docker.pkg.dev/${var.mineservu_project_id}/${google_artifact_registry_repository.mineservu-repo.name}/itzg/minecraft-server"
        ports {
          container_port = 25565
        }
        env {
          name = "EULA"
          value = "TRUE"
        }
        resources {
          limits = { memory = "1024Mi" }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_artifact_registry_repository" "mineservu-repo" {
  location      = var.mineservu_region
  repository_id = "${var.mineservu_project_id}-repository"
  description   = "Docker Hub remote repositorio"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    description = "docker hub"
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}