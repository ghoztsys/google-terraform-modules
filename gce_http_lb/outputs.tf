output "backend_services" {
  description = "The backend service resources."
  value       = [for service in module.backend_service : service.self_link]
}

output "public_ip" {
  description = "The public IP for accessing the load balancer."
  value       = google_compute_global_address.default.address
}

output "ssl_domains" {
  description = "Domain names of Google-managed SSL certificates."
  value       = var.ssl_domains
}
