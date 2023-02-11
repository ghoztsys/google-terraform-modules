output "repos" {
  description = "Created repositories."
  value = transpose({
    for repo in google_artifact_registry_repository.default : "${repo.location}-docker.pkg.dev/${repo.project}/${repo.repository_id}" => [repo.project]
  })
}
