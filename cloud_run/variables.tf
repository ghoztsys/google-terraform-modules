variable "container" {
  description = "Configuration of the container in the Cloud Run service."
  type = object({
    image = string
    env   = optional(map(string), {})
    secrets = optional(map(object({
      key  = optional(string, "latest")
      name = string
    })), {})
  })
}

variable "domain_mapping" {
  default     = null
  description = "The custom domain name to map to the Cloud Run service."
  nullable    = true
  type        = string
}

variable "invokers" {
  default     = []
  description = "Specifies the members who can invoke the Cloud Run service."
  type        = list(string)
}

variable "labels" {
  default     = {}
  description = "Labels to attach to the Cloud Run service."
  type        = map(string)
}

variable "location" {
  default     = "us-central1"
  description = "Location of the Cloud Run service."
  type        = string
}

variable "name" {
  default     = "run"
  description = "The name of the Cloud Run service."
  type        = string
}

variable "project_id" {
  description = "ID of project to create resources in."
  type        = string
}
