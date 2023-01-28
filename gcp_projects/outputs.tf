output "ids" {
  description = "ID(s) of the created project (s)."
  value = {
    for env, proj in google_project.default : env => proj.project_id
  }
}

output "service_accounts" {
  description = "Service account(s) created."
  value = {
    for env, sa in google_service_account.default : env => {
      email         = sa.email
      member        = sa.member
      impersonators = google_service_account_iam_binding.default[env].members
    }
  }
}
