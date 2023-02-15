variable "project_id" {
  description = "ID of project to create the Google Artifact Registry repositories in."
  type = string
}

variable "location" {
  default = "us"
  description = "Location of the repositories (see https://cloud.google.com/artifact-registry/docs/repositories/repo-locations)."
  type = string
}

variable "repo_ids" {
  default = []
  description = "IDs of Google Artifact Registry repositories to create."
  type = list(string)
}
