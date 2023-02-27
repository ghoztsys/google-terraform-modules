variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "service_account" {
  description = "Configuration of the service account to impmersonate."
  type = object({
    account_id   = string
    description  = optional(string)
    display_name = optional(string, "Service account for WIF GKE identity")
    roles        = optional(list(string), [])
  })

  validation {
    condition     = can(regex("[a-z][a-z-]*", var.service_account.account_id))
    error_message = "Invalid characters detected for `service_account.account_id`."
  }
}

variable "k8s_service_account" {
  description = "Configuration of the Kubernetes ServiceAccount to link."
  type = object({
    name      = string
    namespace = optional(string, "default")
  })
}
