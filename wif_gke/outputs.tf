output "service_account" {
  description = "Service account for WIF impersonation."
  value = {
    email  = google_service_account.default.email
    member = google_service_account.default.member
  }
}
