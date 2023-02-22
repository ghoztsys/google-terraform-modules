variable "location" {
  default     = "us"
  description = "Location of the repositories (see https://cloud.google.com/artifact-registry/docs/repositories/repo-locations)."
  type        = string
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "repo_ids" {
  default     = []
  description = "IDs of Google Artifact Registry repositories to create."
  type        = list(string)
}
