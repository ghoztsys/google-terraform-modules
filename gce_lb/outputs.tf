output backend_services {
  description = "The backend service resources."
  value = "${google_compute_backend_service.default.*.self_link}"
}

output external_ip {
  description = "The external IP assigned to the global fowarding rule."
  value = "${google_compute_global_address.default.address}"
}

output ssl_domains {
  description = "Domain names of Google-managed SSL certificates."
  value = "${var.ssl_domains}"
}
