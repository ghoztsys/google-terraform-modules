variable "bucket_location" {
  default     = "US"
  description = "GCS bucket location"
}

variable "default_acl" {
  default     = "publicread"
  description = "Default ACL of the GCS bucket."
  type        = string
}

variable "ip_version" {
  default     = ""
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
}

variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "region" {
  description = "The region where the project resides."
}

variable "ssl_certificate" {
  default     = ""
  description = "Content of the custom SSL certificate."
}

variable "ssl_domains" {
  default     = []
  description = "Specifies the domains for managed SSL certificates."
}

variable "ssl_private_key" {
  default     = ""
  description = "Content of the custom private SSL key."
}

variable "uniform_bucket_level_access" {
  default     = false
  description = "Enables Uniform bucket-level access to the GCS bucket."
  type        = bool
}
