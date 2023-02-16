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

variable "id" {
  description = "Project ID."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.id))
    error_message = "Invalid characters detected in `name_prefix`."
  }
}

variable "use_hex_suffix" {
  default     = true
  description = "Specifies if 6-character hex suffix should be appended to the project ID."
  type        = bool
}

variable "disable_default_service_accounts" {
  default     = false
  description = "Specifies whether default service accounts should be disabled (beta)."
  type        = bool
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

variable "iam_policies" {
  default     = []
  description = "IAM policies for each created project."
  type = list(object({
    members = list(string)
    roles   = list(string)
  }))
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
  default     = "Project-specific Terraform-managed service account"
  description = "Display name of service account(s)."
  type        = string
}

variable "service_account_description" {
  default     = null
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
