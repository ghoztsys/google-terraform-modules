variable project_id {
  description = "Google Cloud Platform project ID."
}

variable region {
  description = "The region where the project resides."
}

variable ip_version {
  default = ""
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
}

variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable enable_http {
  default = true
  description = "Set to `false` to disable HTTP forward to port 80."
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
  default = "HTTP"
  description = "The protocol with which to talk to the backend service."
}

variable ssl_domains {
  default = []
  description = "Specifies the domains for managed SSL certificates."
}

variable ssl_private_key {
  default = ""
  description = "Content of the custom private SSL key."
}

variable ssl_certificate {
  default = ""
  description = "Content of the custom SSL certificate."
}

variable security_policy {
  default = ""
  description = "The resource URL for the security policy to associate with the backend service."
}

variable enable_cdn {
  default = true
  description = "Set to `true` to enable cdn on backend."
}

variable create_url_map {
  default = true
  description = "Specifies whether a default URL map should be generated."
}

variable url_map {
  default = ""
  description = "Provide a custom URL map resource to be used instead of automatically generating one."
}

variable target_tags {
  default = []
  description = "List of target tags for health check firewall rule."
}
