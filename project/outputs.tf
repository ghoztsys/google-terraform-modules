output "name" {
  description = "Project name."
  value = google_project.default.name
}

output "id" {
  description = "Project ID."
  value = google_project.default.project_id
}

output "service_accounts" {
  description = "Terraform-managed service account."
  value = {
    email         = google_service_account.default.email
    member        = google_service_account.default.member
    impersonators = google_service_account_iam_binding.default.members
  }
}
