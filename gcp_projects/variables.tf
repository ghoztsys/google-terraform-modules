variable "parent" {
  description = "ID of the organization of which the project(s) belong(s) to. If set, the project(s) created will be directly under the organization level, so `folder_id` must be `null`."
  type = object({
    type = string
    id   = string
  })

  validation {
    condition     = contains(["organization", "org", "folder"], var.parent.type)
    error_message = "Unrecognized parent type, must be one of: \"organization\", \"org\" or \"folder\"."
  }
}

variable "billing_id" {
  description = "Billing account ID to use for all created projects."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for each project ID."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.name_prefix))
    error_message = "Invalid characters detected in `name_prefix`."
  }
}

variable "disable_default_service_accounts" {
  default     = false
  description = "Specifies whether default service accounts should be disabled (beta)."
  type        = bool
}

variable "environments" {
  default     = []
  description = "A list of supported environments of which one project will be generated per environment."
  type        = list(string)

  validation {
    condition     = alltrue([for v in var.environments : can(regex("[a-z][a-z-]*", v))])
    error_message = "Invalid characters detected in `envs`."
  }
}

variable "labels" {
  default     = {}
  description = "Labels to assign to each created project."
  type        = map(string)
}

variable "enabled_apis" {
  default     = []
  description = "APIs to activate for each created project."
  type        = list(string)
}

variable "service_account_id" {
  default     = "terraform"
  description = "The account ID of the Terraform-managed service account (the username of the email address, i.e. <account_id>@<project_id>.iam.gserviceaccount.com)."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.service_account_id))
    error_message = "Invalid characters detected for `sa_id`."
  }
}

variable "service_account_name" {
  default     = null
  description = "Display name prefix of service account(s)."
  type        = string
}

variable "service_account_description" {
  default     = "Project-specific Terraform-managed service account"
  description = "The description of the service account."
  type        = string
}

variable "service_account_roles" {
  default     = []
  description = "IAM roles to assign to each service account at the project level."
  type        = list(string)
}

variable "service_account_impersonators" {
  default     = []
  description = "Whitelist of IAM members who can impersonate each service account."
  type        = list(string)
}
