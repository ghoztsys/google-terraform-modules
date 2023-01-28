# Create Workload Identity Pool.
resource "google_iam_workload_identity_pool" "default" {
  project                   = var.project_id
  workload_identity_pool_id = var.wif_id
}

# Add GitHub OIDC provider to Workload Identity Pool.
resource "google_iam_workload_identity_pool_provider" "default" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.default.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_id

  attribute_condition = "assertion.repository_owner==\"${var.github_owner}\""
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

# Create service account for WIF impersonation.
resource "google_service_account" "default" {
  account_id   = var.service_account_id
  display_name = coalesce(var.service_account_name, var.service_account_id)
  description  = var.service_account_description
  project      = var.project_id
}

# Bind roles to service account.
resource "google_project_iam_member" "default" {
  for_each = toset(var.service_account_roles)

  member  = "serviceAccount:${google_service_account.default.email}"
  project = var.project_id
  role    = each.key
}

# Link Workload Identity Pool to service account for impersonation.
resource "google_service_account_iam_member" "default" {
  for_each = toset(var.github_repositories)

  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.default.name}/attribute.repository/${each.key}"
}
