variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
  type = string
}

variable network {
  default = "default"
  description = "The name of the network to add the firewall rules to."
  type = string
}

variable backend_services {
  description = "List of maps, each defining a Backend Service/Bucket to be created (all key/value pairs correspond to the parameters of the submodule `https://github.com/sybl/terraform-modules/tree/master/gce_backend_service`). The first Backend Service in the list is the default service applied to the generated URL Map. See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service."
  type = any
}

variable enable_http {
  default = true
  description = "Set to `false` to disable HTTP forward to port 80."
  type = bool
}

variable https_redirect {
  default = true
  description = "Specifies if HTTP traffic should be automatically redirected to HTTPS. This requires `enable_http` to be `true` and that there are SSL certificates/domains configured."
  type = bool
}

variable host_redirect {
  default = null
  description = "Specifies the host to redirect to (by applying `default_url_redirect.host_redirect`), see https://cloud.google.com/load-balancing/docs/url-map-concepts#url-redirects."
  type = string
}

variable ipv6 {
  default = false
  description = "Specifies if IPv6 should be used instead of IPv4 for the global address and forwarding rules."
  type = bool
}

variable ssl_certificate {
  default = ""
  description = "The certificate of the self-signed SSL certificate in PEM format. If specified, the `ssl_private_key` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#certificate (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type = string
}

variable ssl_private_key {
  default = ""
  description = "The write-only private key of the self-signed SSL certificate in PEM format. If specified, the `ssl_certificate` variable must also be set. This property is sensitive and will not be displayed in the plan. See google_compute_ssl_certificate#private_key (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate)."
  type = string
}

variable ssl_domains {
  default = []
  description = "Specifies the domains for managed SSL certificates."
  type = list(string)
}

variable url_map {
  default = []
  description = "A map that describes how the URL map should be constructed."
  type = any
  # type = list(object({
  #   hosts = list(string)
  #   default_backend_service_index = number
  #   path_rules = list(object({
  #     paths = list(string)
  #     backend_service_index = number
  #   }))
  # }))
}
