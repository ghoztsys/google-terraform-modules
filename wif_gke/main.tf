# Create service account for WIF impersonation.
resource "google_service_account" "default" {
  account_id   = var.service_account.account_id
  description  = var.service_account.description
  display_name = var.service_account.display_name
  project      = var.project
}

# Bind roles to service account.
resource "google_project_iam_member" "default" {
  for_each = toset(var.service_account.roles)

  member  = google_service_account.default.member
  project = var.project
  role    = each.key
}

# Link service account to Kubernetes service account.
resource "google_service_account_iam_member" "default" {
  member             = "serviceAccount:${var.project}.svc.id.goog[${var.k8s_service_account.namespace}/${var.k8s_service_account.name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.default.name
}
