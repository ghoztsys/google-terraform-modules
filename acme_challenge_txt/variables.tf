variable "project_id" {
  description = "ID of project to create resources in."
  type        = string
}

variable "dns_name" {
  description = "The target DNS name, i.e. `ghozt.io.`"
  type        = string
}

variable "dns_managed_zone" {
  description = "The name of the DNS managed zone."
  type        = string
}

variable "subdomain" {
  default     = ""
  description = "The subdomain, i.e. `api`. Leave blank if this is not a subdomain."
  type        = string
}

variable "text" {
  description = "The TXT record value."
  type        = string
}
