locals {
    artifact_repository_url = "${var.mineservu_region}-docker.pkg.dev/${var.mineservu_project_id}/${google_artifact_registry_repository.mineservu-repo.name}"
}