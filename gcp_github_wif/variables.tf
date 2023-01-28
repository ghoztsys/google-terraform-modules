variable "project_id" {
  description = "ID of the project to create WIF resources in."
  type        = string
}

variable "wif_id" {
  description = "String identifier to prepend to all WIF resources."
  type        = string
}

variable "github_owner" {
  description = "Owner of GitHub repositories that will access GCP resources via WIF."
  type        = string
}

variable "github_repositories" {
  default     = []
  description = "GitHub repositories that will access GCP resources via WIF (format: <owner>/<repo>)."
  type        = list(string)
}

variable "service_account_id" {
  description = "Account ID of the service account to impersonate (the username of the email address, i.e. <account_id>@<project_id>.iam.gserviceaccount.com)."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.service_account_id))
    error_message = "Invalid characters detected for `service_account_id`."
  }
}

variable "service_account_name" {
  default     = "Service account for WIF GitHub identity"
  description = "Name of the service account to impersonate."
  type        = string
}

variable "service_account_description" {
  default     = null
  description = "Description of the service account to impersonate."
  type        = string
}

variable "service_account_roles" {
  default     = []
  description = "Roles to assign to the service account on the project level."
  type        = list(string)
}
