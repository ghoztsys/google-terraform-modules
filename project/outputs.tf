output "name" {
  description = "Project name."
  value       = google_project.default.name
}

output "id" {
  description = "Project ID."
  value       = google_project.default.project_id
}

output "service_account" {
  description = "Terraform-managed service account."
  value       = module.service_account
}
