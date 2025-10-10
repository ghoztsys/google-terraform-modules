output "name" {
  description = "The bucket name."
  value       = google_storage_bucket.default.name
}

output "backend_bucket" {
  description = "The backend bucket."
  value       = google_compute_backend_bucket.default.name
}

output "external_ip" {
  description = "The external IP assigned to the global fowarding rule."
  value       = google_compute_global_address.default.address
}

output "ssl_domains" {
  description = "Domain names of Google-managed SSL certificates."
  value       = var.ssl_domains
}

output "url_map" {
  description = "The URL map."
  value       = google_compute_url_map.default.name
}
