variable "billing_id" {
  description = "Billing account ID to use for all created projects."
  type        = string
}

variable "disable_default_service_accounts" {
  default     = false
  description = "Specifies whether default service accounts should be disabled (beta)."
  type        = bool
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

variable "id" {
  description = "Project ID."
  type        = string

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.id))
    error_message = "Invalid characters detected in `name_prefix`."
  }
}

variable "labels" {
  default     = {}
  description = "Labels to assign to each created project."
  type        = map(string)
}

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

variable "service_account" {
  description = "Terraform-managed service account specific to this project."
  type = object({
    name          = optional(string, "Project-specific Terraform-managed service account")
    id            = optional(string, "terraform")
    description   = optional(string)
    roles         = optional(list(string), [])
    impersonators = optional(list(string), [])
  })
}

variable "use_hex_suffix" {
  default     = true
  description = "Specifies if 6-character hex suffix should be appended to the project ID."
  type        = bool
}
