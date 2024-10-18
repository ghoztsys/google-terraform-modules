variable "backend_services" {
  description = "Configuration for each `backend_service` module."
  type = list(object({
    acl = optional(string, "publicread")
    backends = optional(list(object({
      balancing_mode               = optional(string)
      capacity_scaler              = optional(number)
      description                  = optional(string)
      group                        = string
      max_connections              = optional(number)
      max_connections_per_instance = optional(number)
      max_rate                     = optional(number)
      max_rate_per_instance        = optional(number)
      max_utilization              = optional(number)
      port                         = optional(number, 8080)
      target_tags                  = optional(list(string), [])
    })), [])
    cors = optional(object({
      origin          = optional(list(string))
      method          = optional(list(string))
      response_header = optional(list(string))
      max_age_seconds = optional(number)
    }), {})
    enable_logging = optional(bool, true)
    enable_cdn     = optional(bool, false)
    health_checks = optional(list(object({
      path = optional(string, "/health")
      port = optional(number)
    })), [])
    labels                      = optional(map(string), {})
    port_name                   = optional(string)
    protocol                    = optional(string, "HTTP")
    security_policy             = optional(string, null)
    timeout                     = optional(number)
    type                        = optional(string, "service")
    uniform_bucket_level_access = optional(bool, false)
    versioning                  = optional(bool, false)
  }))
}

variable "enable_http" {
  default     = true
  description = "Set to `false` to disable HTTP forward to port 80."
  type        = bool
}

variable "host_redirect" {
  default     = null
  description = "Specifies the host to redirect to (by applying `default_url_redirect.host_redirect`), see https://cloud.google.com/load-balancing/docs/url-map-concepts#url-redirects."
  type        = string
}

variable "https_redirect" {
  default     = true
  description = "Specifies if HTTP traffic should be automatically redirected to HTTPS. This requires `enable_http` to be `true` and that there are SSL certificates/domains configured."
  type        = bool
}

variable "name" {
  default     = "lb"
  description = "Name for the forwarding rule and prefix for supporting resources."
  type        = string
}

variable "network" {
  default     = "default"
  description = "The name of the network to add the firewall rules to."
  type        = string
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "region" {
  description = "Region of the load balancer (Standard Tier). Note that Standard Tier is only available in select regions, see https://cloud.google.com/network-tiers/docs/overview#regions_supporting_standard_tier."
  type        = string
}

variable "ssl_certificate" {
  default     = ""
  description = "The certificate of the self-signed SSL certificate in PEM format. If specified, the `ssl_private_key` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#certificate (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type        = string
}

variable "ssl_domains" {
  default     = []
  description = "Specifies the domains for managed SSL certificates."
  type        = list(string)
}

variable "ssl_private_key" {
  default     = ""
  description = "The write-only private key of the self-signed SSL certificate in PEM format. If specified, the `ssl_certificate` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#private_key (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type        = string
}

variable "url_map" {
  default     = []
  description = "A map that describes how the URL map should be constructed."
  type = list(object({
    default_url_redirect = optional(object({
      host_redirect          = string
      redirect_response_code = optional(string, "MOVED_PERMANENTLY_DEFAULT")
      strip_query            = optional(bool, false)
    }))
    default_backend_service_index = optional(number, 0)
    hosts                         = list(string)
    path_rules = optional(list(object({
      paths                 = list(string)
      backend_service_index = optional(number, 0)
    })), [])
  }))
}
