output "name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_service.default.name
}

output "public_url" {
  description = "Public IP of the Cloud Run service."
  value       = google_cloud_run_service.default.status[0].url
}

output "service_account" {
  description = "The service account email associated with the Cloud Run service."
  value       = google_cloud_run_service.default.template[0].spec[0].service_account_name
}
