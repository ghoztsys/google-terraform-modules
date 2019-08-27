output public_ip {
  description = "Public IP of the created sandbox VM instance."
  value = google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip
}

output service_id {
  description = "Service ID of the module."
  value = var.service_id
}
