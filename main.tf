terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.77.0"
    }
  }
}

provider "google" {
  project = var.mineservu_project_id
  region  = var.mineservu_region
  zone    = var.mineservu_zone
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

resource "google_compute_instance" "minecraft-server-instance" {
  provider      = google
  name          = "minecraft-server"
  machine_type  = "e2-medium"

  metadata = {
    ssh-keys = "tanelig:${file("~/.ssh/id_rsa.pub")}"
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  network_interface {
    network     = google_compute_network.mc-ipv6net.id
    subnetwork  = google_compute_subnetwork.mc-ipv6subnet.id
    stack_type  = "IPV4_IPV6"
    access_config {
      nat_ip        = google_compute_address.mc-server-static-ip.address
      network_tier  = "PREMIUM"
    }

    ipv6_access_config {
      network_tier  = "PREMIUM"
    }
  }

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  allow_stopping_for_update = true
  tags = ["container-vm-example"]

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

   service_account {
    email   = var.service_account_email
    scopes  = [
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

resource "google_compute_address" "mc-server-static-ip" {
  provider      = google
  name          = "static-ip"
  address_type  = "EXTERNAL"
  network_tier  = "PREMIUM"
}

resource "google_compute_network" "mc-ipv6net" {
  provider                = google
  name                    = "mc-ipv6net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mc-ipv6subnet" {
  provider          = google
  name              = "ipv6subnet"
  network           = google_compute_network.mc-ipv6net.id
  ip_cidr_range     = "10.0.0.0/8"
  stack_type        = "IPV4_IPV6"
  ipv6_access_type  = "EXTERNAL"
}

resource "google_compute_firewall" "mc-firewall" {
  provider  = google
  name      = "firewall"
  network   = google_compute_network.mc-ipv6net.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22", "25565"]
  }
}

module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "${local.artifact_repository_url}/itzg/minecraft-server"
    env   = [
      {
        name  = "EULA"
        value = "TRUE"
      }
    ]
  }
}