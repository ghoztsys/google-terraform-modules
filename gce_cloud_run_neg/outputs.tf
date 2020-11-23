output neg_id {
  description = ""
  value = google_compute_region_network_endpoint_group.default.id
}

output name {
  description = "Name of the Cloud Run service."
  value = google_compute_region_network_endpoint_group.default.name
}
