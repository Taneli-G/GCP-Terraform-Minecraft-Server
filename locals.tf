locals {
  # Minecraft server URL from virtual artifact registry
  artifact_repository_url = "${var.mineservu_region}-docker.pkg.dev/${var.mineservu_project_id}/${google_artifact_registry_repository.mc_main.name}"
}