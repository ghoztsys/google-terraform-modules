locals {
  registry = "${var.location}-docker.pkg.dev/${var.project_id}"
}

output "registry" {
  description = "Host URL of Google Artifact Registry resource."
  value = local.registry
}

output "repos" {
  description = "Created repositories."
  value = [
    for repo in google_artifact_registry_repository.default : "${local.registry}/${repo.repository_id}"
  ]
}
