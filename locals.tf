locals {
  # Minecraft server URL from virtual artifact registry
  artifact_repository_url = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.mc_main.name}"
}