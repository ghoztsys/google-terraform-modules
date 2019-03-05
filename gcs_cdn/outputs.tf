output backend_bucket {
  description = "The backend bucket."
  value = "${google_compute_backend_bucket.default.self_link}"
}

output external_ip {
  description = "The external IP assigned to the global fowarding rule."
  value = "${google_compute_global_address.default.address}"
}
