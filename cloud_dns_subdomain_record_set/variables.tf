variable "managed_zone" {
  description = "Name of the Cloud DNS managed zone."
  type        = string
}

variable "name" {
  description = "Name of the record set."
  type        = string
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "ttl" {
  default     = 300
  description = "The TTL to set on the record set(s)."
  type        = number
}
