output "projects" {
  description = "The created project(s)."
  value = {
    for env, proj in google_project.default : env => {
      name = proj.name
      id   = proj.project_id
    }
  }
}

output "service_accounts" {
  description = "The created service account(s)."
  value = {
    for env, sa in google_service_account.default : env => {
      email         = sa.email
      member        = sa.member
      impersonators = google_service_account_iam_binding.default[env].members
    }
  }
}
