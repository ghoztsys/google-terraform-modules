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

# Bind general IAM policies to project.
module "iam_project" {
  source = "../iam_project"

  policies = var.iam_policies
  project  = google_project.default.project_id
}

module "service_account" {
  source = "../service_account"

  description   = var.service_account.description
  id            = var.service_account.id
  impersonators = var.service_account.impersonators
  name          = var.service_account.name
  project       = google_project.default.project_id
  roles         = var.service_account.roles
}
