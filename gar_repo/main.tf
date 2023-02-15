resource "google_artifact_registry_repository" "default" {
  for_each = toset(var.repo_ids)

  format        = "DOCKER"
  location      = var.location
  project       = var.project_id
  repository_id = each.value
}
