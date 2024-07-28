variable "description" {
  default     = null
  description = "The description of the service account."
  type        = string
}

variable "id" {
  description = "The account ID of the Terraform-managed service account (the username of the email address, i.e. <account_id>@<project_id>.iam.gserviceaccount.com)."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.id))
    error_message = "Invalid characters detected for `id`."
  }
}

variable "impersonators" {
  default     = []
  description = "Whitelist of IAM members who can impersonate each service account."
  type        = list(string)
}

variable "name" {
  description = "Display name of the service account."
  type        = string
}

variable "project" {
  description = "ID of project to create the service account in."
  type        = string
}

variable "roles" {
  default     = []
  description = "IAM roles to assign to the service account."
  type        = list(string)
}
