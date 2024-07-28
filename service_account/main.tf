# Create Terraform-managed service account.
resource "google_service_account" "default" {
  account_id   = var.id
  description  = var.description
  display_name = var.name
  project      = var.project
}

# Bind IAM policies for Terraform-managed service account to project.
resource "google_project_iam_member" "default" {
  for_each = toset(var.roles)

  member  = google_service_account.default.member
  project = var.project
  role    = each.value
}

# Bind IAM policies to service accounts to whitelist impersonators.
resource "google_service_account_iam_binding" "default" {
  members            = var.impersonators
  role               = "roles/iam.serviceAccountTokenCreator"
  service_account_id = google_service_account.default.name
}
