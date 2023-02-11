locals {
  repos_map = flatten([
    for project_id in var.project_ids : [
      for repo_id in var.repo_ids : {
        project_id = project_id
        repo_id    = repo_id
      }
    ]
  ])
}

resource "google_artifact_registry_repository" "default" {
  for_each = { for descriptor in local.repos_map : "${descriptor.project_id}+${descriptor.repo_id}" => descriptor }

  format        = "DOCKER"
  location      = var.location
  project       = each.value.project_id
  repository_id = each.value.repo_id
}
