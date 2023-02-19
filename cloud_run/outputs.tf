output "public_url" {
  description = "Public IP of the Cloud Run service."
  value       = google_cloud_run_service.default.status[0].url
}
