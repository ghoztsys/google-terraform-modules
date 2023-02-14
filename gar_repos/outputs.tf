output "registries" {
  description = "Host URLs of Google Artifact Registry resources."
  value = {
    for project_id in var.project_ids : project_id => "${var.location}-docker.pkg.dev/${project_id}"
  }
}

output "repos" {
  description = "Created repositories."
  value = transpose({
    for repo in google_artifact_registry_repository.default : "${repo.location}-docker.pkg.dev/${repo.project}/${repo.repository_id}" => [repo.project]
  })
}
