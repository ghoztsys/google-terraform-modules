variable region {
  description = "Region of the load balancer (Standard Tier). Note that Standard Tier is only available in select regions, see https://cloud.google.com/network-tiers/docs/overview#regions_supporting_standard_tier."
  type = string
}

variable backend_services {
  description = "List of maps, each defining a Backend Service to be created. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service."
  type = list
  # type = list(object({
  #   health_checks = list(object({ path = string, port = number })) # Health check ports/paths for all backends in the current Backend Service.
  #   path_rules = list(string) # Path rules to add to the generated URL map for directing traffic to the current Backend Service.
  #   port_name = string # Named port to direct load-balanced packets to. This is only applicable to instance groups (not NEGs), and if available, must have at least one port with the same name.
  #   protocol = string # The protocol the current Backend Service uses to communicate with its backends.
  #   security_policy = string # The resource URL for the security policy to associate with the current Backend Service.
  #   timeout = number # Specifies how many seconds to wait for a backend to respond before reporting failure.
  # }))
}

variable backend_buckets {
  default = []
  description = "List of maps, each defining a Backend Bucket to be created."
  type = list
  # type = list(object({
  #   default_acl = string # Default ACL of the GCS bucket associated with the current Backend Bucket.
  #   path_rules = list(string) # Path rules to add to the generated URL map for directing traffic to the current Backend Bucket.
  #   versioning = bool # Specifies if versioning is enabled for the GCS bucket.
  # }))
}

variable backends {
  description = "Fully-qualified URLs of the Instance Groups or Network Endpoint Groups (NEG) of each Backend Service created. Note that each Backend Service resource can have more than one virtual machine to serve traffic for load balancing. This variable is a list of lists and must be one-to-one mappable to the list structure as defined by the variable `backend_services` (i.e. the first element of this list, which is a list of URLs, represents the URLs of all the instance groups used by the first Backend Service resource defined in `backend_services`). Note that this variable is intentionally separate from the `backend_services` variable due to the fact that the creation of Backend Services is done via `for_each`, and as of Terraform v0.13.5, `for_each` cannot depend on resource attributes that cannot be determined until apply (i.e. a dynamic variable such as this which is potentially derived from the outputs of other Terraform resources)."
  type = list
  # type = list(list(object({
  #   balancing_mode = string
  #   capacity_scaler = number
  #   description = string
  #   group = list(string)
  #   max_connections = number
  #   max_connections_per_instance = number
  #   max_rate = number
  #   max_rate_per_instance = number
  #   max_utilization = number
  #   port = number # Port accepting load-balanced packets.
  #   target_tags = list(string) # List of target tags assigned to the VMs to be used for creating health check firewall rules.
  # })))
}

variable enable_http {
  default = true
  description = "Set to `false` to disable HTTP forward to port 80."
  type = bool
}

variable redirect_http {
  default = true
  description = "Specifies if HTTP traffic should be automatically redirected to HTTPS. This requires `enable_http` to be `true` and that there are SSL certificates/domains configured."
  type = bool
}

variable ip_version {
  default = ""
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
  type = string
}

variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
  type = string
}

variable ssl_certificate {
  default = ""
  description = "The certificate of the self-signed SSL certificate in PEM format. If specified, the `ssl_private_key` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#certificate (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type = string
}

variable ssl_private_key {
  default = ""
  description = "THe write-only private key of the self-signed SSL certificate in PEM format. If specified, the `ssl_certificate` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#private_key (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type = string
}

variable ssl_domains {
  default = []
  description = "Specifies the domains for managed SSL certificates."
  type = list(string)
}

variable create_url_map {
  default = true
  description = "Specifies whether a URL map should be automatically generated based on the provided `backend_services` and `backend_buckets`."
  type = bool
}

variable url_map {
  default = null
  description = "URI of the custom URL map resource to be used instead of automatically generated one, (i.e. google_compute_url_map.<name>.self_link)"
  type = string
}
