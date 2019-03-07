variable project_id {
  description = "Google Cloud Platform project ID."
}

variable region {
  description = "The region where the project resides."
}

variable ip_version {
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
  default = ""
}

variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable enable_http {
  description = "Set to `false` to disable HTTP forward to port 80."
  default = true
}

variable backend_services {
  description = "Map backend service indices to list of backend maps."
  type = "map"
}

variable backend_service_params {
  description = "Comma-separated encoded list of parameters in order: health check path, service port name, service port, backend timeout seconds."
  type = "list"
}

variable backend_protocol {
  description = "The protocol with which to talk to the backend service."
  default = "HTTP"
}

variable ssl_domains {
  description = "Specifies the domains for managed SSL certificates."
  default = []
}

variable ssl_private_key {
  description = "Content of the custom private SSL key."
  default = ""
}

variable ssl_certificate {
  description = "Content of the custom SSL certificate."
  default = ""
}

variable security_policy {
  description = "The resource URL for the security policy to associate with the backend service."
  default = ""
}

variable enable_cdn {
  description = "Set to `true` to enable cdn on backend."
  default = true
}

variable create_url_map {
  description = "Specifies whether a default URL map should be generated."
  default = true
}

variable url_map {
  description = "Provide a custom URL map resource to be used instead of automatically generating one."
  default = ""
}

variable target_tags {
  description = "List of target tags for health check firewall rule."
  default = []
}
