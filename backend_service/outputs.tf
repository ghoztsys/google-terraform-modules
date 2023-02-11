output "self_link" {
  description = "The created Backend Service/Bucket resource."
  value       = var.type == "service" ? google_compute_backend_service.default[0].self_link : google_compute_backend_bucket.default[0].self_link
}
