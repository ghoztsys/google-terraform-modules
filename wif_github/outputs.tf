output "github" {
  description = "Whitelisted GitHub resources."
  value = {
    owner        = var.github_owner
    repositories = var.github_repositories
  }
}

output "pool" {
  description = "Workload Identity Federation pool."
  value = {
    id   = google_iam_workload_identity_pool.default.id
    name = google_iam_workload_identity_pool.default.name
  }
}

output "provider" {
  description = "Workload Identity Federation pool provider."
  value = {
    id   = google_iam_workload_identity_pool_provider.default.id
    name = google_iam_workload_identity_pool_provider.default.name
  }
}

output "service_account" {
  description = "Service account for WIF impersonation."
  value = {
    email  = google_service_account.default.email
    member = google_service_account.default.member
  }
}
