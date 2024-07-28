output "email" {
  description = "Email of the created service account."
  value       = google_service_account.default.email
}

output "member" {
  description = "Member of the service account."
  value       = google_service_account.default.member
}

output "email" {
  description = "Impersonators of the service account."
  value       = google_service_account_iam_binding.default.members
}
