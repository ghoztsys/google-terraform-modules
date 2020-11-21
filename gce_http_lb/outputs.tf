output backend_services {
  description = "The backend service resources."
  value = [for service in google_compute_backend_service.default : service.self_link]
}

output backend_buckets {
  description = "The backend bucket resources."
  value = [for bucket in google_compute_backend_bucket.default : bucket.self_link]
}

output public_ip {
  description = "The public IP for accessing the load balancer."
  value = google_compute_global_address.default.address
}

output ssl_domains {
  description = "Domain names of Google-managed SSL certificates."
  value = var.ssl_domains
}
