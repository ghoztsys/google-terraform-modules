resource "google_artifact_registry_repository" "default" {
  for_each = toset(var.repo_ids)

  format        = "DOCKER"
  location      = var.location
  project       = var.project
  repository_id = each.value
}
