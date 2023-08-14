output "service_url" {
    value = google_cloud_run_service.run_service.status[0].url
}

output "artifact_registry_path" {
    value = google_artifact_registry_repository.mineservu-repo
}