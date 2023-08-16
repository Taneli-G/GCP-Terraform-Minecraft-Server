terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.77.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Virtual artifact registry to access Docker Hub
resource "google_artifact_registry_repository" "mc_main" {
  location      = var.region
  repository_id = "${var.project_id}-repository"
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

# Persistent data disk for minecraft server data
resource "google_compute_disk" "mc_main" {
  project = var.project_id
  name    = var.mc_disk_name
  type    = "pd-ssd"
  zone    = var.zone
  size    = 25
}

# The Container optimized VM for Minecraft server.
# Starts Minecraft server Docker container on server startup.
resource "google_compute_instance" "mc_main" {
  provider     = google
  name         = "minecraft-server"
  machine_type = "e2-medium"

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  network_interface {
    network    = google_compute_network.mc_main.id
    subnetwork = google_compute_subnetwork.mc_main.id
    stack_type = "IPV4_ONLY"
    access_config {
      nat_ip = google_compute_address.mc_ip.address
    }
  }

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  attached_disk {
    source      = google_compute_disk.mc_main.self_link
    device_name = "data-disk-0"
    mode        = "READ_WRITE"
  }

  allow_stopping_for_update = true
  tags                      = ["container-vm-minecraft-server"]

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}

# Static IP for Minecraft server
resource "google_compute_address" "mc_ip" {
  provider     = google
  name         = "mc-static-ip"
  address_type = "EXTERNAL"
}

# Network for Minecraft server
resource "google_compute_network" "mc_main" {
  provider                = google
  name                    = "mc-ipv4net"
  auto_create_subnetworks = false
}

# Subnet for Minecraft server
resource "google_compute_subnetwork" "mc_main" {
  provider      = google
  name          = "mc-ipv4subnet"
  network       = google_compute_network.mc_main.id
  ip_cidr_range = "10.0.0.0/8"
  stack_type    = "IPV4_ONLY"
}

# Firewall and rules for Minecraft server
resource "google_compute_firewall" "mc_main" {
  provider = google
  name     = "mc-firewall"
  network  = google_compute_network.mc_main.name

  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
}

# Metadata creation for Container-Optimized VM. Define Minecraft Server Docker image and mounts.
module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${local.artifact_repository_url}/itzg/minecraft-server"
    env = [
      {
        name  = "EULA"
        value = "TRUE"
      },
      {
        name  = "MEMORY"
        value = "3G"
      },
      {
        name  = "SERVER_NAME"
        value = "Your-server-name"
      }
    ]
    volumeMounts = [
      {
        mountPath = "/data"
        name      = "data-disk-0"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "data-disk-0"

      gcePersistentDisk = {
        pdName = "data-disk-0"
        fsType = "ext4"
      }
    }
  ]
}