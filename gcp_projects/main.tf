locals {
  apis_map = flatten([
    for env in local.environments : [
      for api in var.enabled_apis : {
        api         = api
        environment = env
      }
    ]
  ])
  roles_map = flatten([
    for env in local.environments : [
      for role in var.service_account_roles : {
        environment = env
        role        = role
      }
    ]
  ])
  environments              = local.has_multiple_environments ? var.environments : ["default"]
  has_multiple_environments = length(var.environments) > 0
}

# Declare IAM policies for projects.
data "google_iam_policy" "project" {
  for_each = google_service_account.default

  dynamic "binding" {
    for_each = toset(var.service_account_roles)

    content {
      role    = binding.value
      members = ["serviceAccount:${each.value.email}"]
    }
  }
}

# Generate random string identifier for each environment.
resource "random_id" "default" {
  for_each = toset(local.environments)

  byte_length = 3

  keepers = {
    environment = each.value
  }
}

# Create a project for each environment.
resource "google_project" "default" {
  for_each = toset(local.environments)

  billing_account = var.billing_id
  folder_id       = var.parent.type == "folder" ? var.parent.id : null
  name            = "${var.name_prefix}${local.has_multiple_environments ? "-${each.value}" : ""}"
  org_id          = (var.parent.type == "organization" || var.parent.type == "org") ? var.parent.id : null
  project_id      = "${var.name_prefix}${local.has_multiple_environments ? "-${each.value}" : ""}-${random_id.default[each.value].hex}"

  labels = merge(var.labels, local.has_multiple_environments ? {
    environment = each.value
  } : {})
}

# Activate necessary APIs.
resource "google_project_service" "default" {
  for_each = { for descriptor in local.apis_map : "${descriptor.environment}+${descriptor.api}" => descriptor }

  disable_dependent_services = true
  project                    = google_project.default[each.value.environment].project_id
  service                    = each.value.api
}

module "project_iam" {
  for_each = google_project.default

  source = "../gcp_project_iam"

  policies   = var.iam_policies
  project_id = each.value.project_id
}

# Disable creating default service accounts when certain APIs are activated.
# resource "google_project_default_service_accounts" "default" {
#   for_each = var.disable_default_service_accounts ? google_project.default : {}

#   action  = "DELETE"
#   project = each.value.project_id
# }

# Create Terraform-managed service account per project.
resource "google_service_account" "default" {
  for_each = google_project.default

  account_id   = var.service_account_id
  description  = var.service_account_description
  display_name = var.service_account_name
  project      = each.value.project_id
}

# Bind IAM policies to projects.
resource "google_project_iam_member" "default" {
  for_each = { for descriptor in local.roles_map : "${descriptor.environment}+${descriptor.role}" => descriptor }

  member  = google_service_account.default[each.value.environment].member
  project = google_project.default[each.value.environment].project_id
  role    = each.value.role
}

# Bind IAM policies to service accounts to whitelist impersonators.
resource "google_service_account_iam_binding" "default" {
  for_each = google_service_account.default

  members            = var.service_account_impersonators
  role               = "roles/iam.serviceAccountTokenCreator"
  service_account_id = each.value.name
}
