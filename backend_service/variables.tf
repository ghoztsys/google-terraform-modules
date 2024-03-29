variable "backends" {
  default     = []
  description = "Fully-qualified URLs of the Instance Groups or Network Endpoint Groups (NEG) of each Backend Service created. Note that each Backend Service resource can have more than one virtual machine to serve traffic for load balancing. This variable is a list of lists and must be one-to-one mappable to the list structure as defined by the variable `backend_services` (i.e. the first element of this list, which is a list of URLs, represents the URLs of all the instance groups used by the first Backend Service resource defined in `backend_services`). Note that this variable is intentionally separate from the `backend_services` variable due to the fact that the creation of Backend Services is done via `for_each`, and as of Terraform v0.13.5, `for_each` cannot depend on resource attributes that cannot be determined until apply (i.e. a dynamic variable such as this which is potentially derived from the outputs of other Terraform resources) (NOTE: This variable is only used if `type` is `service`)."
  type = list(object({
    balancing_mode               = optional(string)
    capacity_scaler              = optional(number)
    description                  = optional(string)
    group                        = string
    max_connections              = optional(number)
    max_connections_per_instance = optional(number)
    max_rate                     = optional(number)
    max_rate_per_instance        = optional(number)
    max_utilization              = optional(number)
    port                         = optional(number, 8080)     # Port accepting load-balanced packets.
    target_tags                  = optional(list(string), []) # List of target tags assigned to the VMs to be used for creating health check firewall rules.
  }))
}

variable "cors" {
  default     = {}
  description = "CORS configuration (NOTE: This variable is only used if `type` is `bucket`)."
  type = object({
    origin          = optional(list(string))
    method          = optional(list(string))
    response_header = optional(list(string))
    max_age_seconds = optional(number)
  })
}

variable "acl" {
  default     = "publicread"
  description = "Default ACL of the GCS bucket associated with the current Backend Bucket (NOTE: This variable is only used if `type` is `bucket`)."
  type        = string
}

variable "enable_cdn" {
  default     = false
  description = "Specifies if Cloud CDN should be enabled (only applies if this is not a regional Backend Service)."
  type        = bool
}

variable "enable_logging" {
  default     = true
  description = "Specifies if logging is enabled."
  type        = bool
}

variable "health_checks" {
  default     = []
  description = "Health check ports/paths for all backends in this Backend Service (NOTE: This variable is only used if `type` is `service`)."
  type = list(object({
    path = optional(string, "/health")
    port = optional(number)
  }))
}

variable "labels" {
  default     = {}
  description = "A set of key/value label pairs to assign to the GCS bucket (NOTE: This variable is only used if `type` is `bucket`)."
  type        = map(string)
}

variable "location" {
  default     = "US"
  description = "Location of the current Backend Bucket (if `regional` is `true`, this value must represent a region) (NOTE: This variable is only used if `type` is `bucket`). For a list of supported values, see https://cloud.google.com/storage/docs/locations."
  type        = string
}

variable "name" {
  description = "Prefix for provisioned resources."
  type        = string
}

variable "network" {
  default     = "default"
  description = "The name of the network to add the firewall rules to."
  type        = string
}

variable "port_name" {
  default     = null
  description = "Named port to direct load-balanced packets to. This is only applicable to backends as instance groups (not NEGs) which, if available, must have at least one port with the same name (NOTE: This variable is only used if `type` is `service`)."
  nullable    = true
  type        = string
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "protocol" {
  default     = "HTTP"
  description = "The protocol the current Backend Service uses to communicate with its backends (NOTE: This variable is only used if `type` is `service`)."
  type        = string

  validation {
    condition     = (var.protocol == "HTTP" || var.protocol == "HTTPS")
    error_message = "The only accepted values are 'HTTP' and 'HTTPS'."
  }
}

variable "regional" {
  default     = false
  description = "Indicates whether created resources should be regional instead of global. When `true`, `enable_cdn` will have no effect."
  type        = bool
}

variable "security_policy" {
  default     = null
  description = "The resource URL for the security policy to associate with this Backend Service (NOTE: This variable is only used if `type` is `service`)."
  type        = string
}

variable "timeout" {
  default     = null
  description = "Specifies how many seconds to wait for a backend to respond before reporting failure (NOTE: This variable is only used if `type` is `service`)."
  type        = number
}

variable "type" {
  default     = "service"
  description = "The type of backend service, accepted values are 'service' and 'bucket'. Defaults to 'service'."
  type        = string

  validation {
    condition     = contains(["service", "bucket"], var.type)
    error_message = "The only accepted values are 'service' and 'bucket'."
  }
}

variable "uniform_bucket_level_access" {
  default     = false
  description = "Enables Uniform bucket-level access to the GCS bucket (NOTE: This variable is only used if `type` is `bucket`)."
  type        = bool
}

variable "versioning" {
  default     = false
  description = "Specifies if versioning is enabled for the GCS bucket (NOTE: This variable is only used if `type` is `bucket`)."
  type        = bool
}
