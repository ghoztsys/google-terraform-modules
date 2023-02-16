# If enabled, generate random 6-character string to append to the project ID.
resource "random_id" "default" {
  count = var.use_hex_suffix ? 1 : 0

  byte_length = 3

  keepers = {
    id = var.id
  }
}

resource "google_project" "default" {
  billing_account = var.billing_id
  folder_id       = var.parent.type == "folder" ? var.parent.id : null
  labels          = var.labels
  name            = var.id
  org_id          = (var.parent.type == "organization" || var.parent.type == "org") ? var.parent.id : null
  project_id      = "${var.id}${var.use_hex_suffix ? "-${random_id.default[0].hex}" : ""}"
}

# Activate necessary APIs.
resource "google_project_service" "default" {
  for_each = toset(var.enabled_apis)

  disable_dependent_services = true
  disable_on_destroy         = false
  project                    = google_project.default.project_id
  service                    = each.value
}

# Disable creating default service accounts when certain APIs are activated.
resource "google_project_default_service_accounts" "default" {
  count = var.disable_default_service_accounts ? 1 : 0

  action  = "DELETE"
  project = google_project.default.project_id
}

# Create Terraform-managed service account.
resource "google_service_account" "default" {
  account_id   = var.service_account_id
  description  = var.service_account_description
  display_name = var.service_account_name
  project      = google_project.default.project_id
}

# Bind general IAM policies to project.
module "iam_project" {
  source = "../iam_project"

  policies   = var.iam_policies
  project_id = google_project.default.project_id
}

# Bind IAM policies for Terraform-managed service account to project.
resource "google_project_iam_member" "default" {
  for_each = toset(var.service_account_roles)

  member  = google_service_account.default.member
  project = google_project.default.project_id
  role    = each.value
}

# Bind IAM policies to service accounts to whitelist impersonators.
resource "google_service_account_iam_binding" "default" {
  members            = var.service_account_impersonators
  role               = "roles/iam.serviceAccountTokenCreator"
  service_account_id = google_service_account.default.name
}
