output "minecraft_server_ip" {
  value = google_compute_address.mc_ip.address
}

output "startup_function_uri" {
  value = google_cloudfunctions2_function.default_start.service_config[0].uri
}

output "shutdown_function_uri" {
  value = google_cloudfunctions2_function.default_stop.service_config[0].uri
}