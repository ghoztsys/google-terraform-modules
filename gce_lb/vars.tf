variable backend_protocol {
  default = "HTTP"
  description = "The protocol with which to talk to the backend service."
}

variable backend_services {
  description = "List of `backend` blocks per backend service."
  type = list(any)
}

variable backend_services_params {
  description = "List of backend service param maps with the following available fields: `health_check_path`, `port_name`, `port`, `timeout` (in seconds)."
  type = list(any)
}

variable create_url_map {
  default = true
  description = "Specifies whether a default URL map should be generated."
}

variable enable_cdn {
  default = true
  description = "Set to `true` to enable cdn on backend service(s)."
}

variable enable_http {
  default = true
  description = "Set to `false` to disable HTTP forward to port 80."
}

variable ip_version {
  default = ""
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
}

variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable project_id {
  description = "Google Cloud Platform project ID."
}

variable region {
  description = "The region where the project resides."
}

variable security_policy {
  default = ""
  description = "The resource URL for the security policy to associate with the backend service(s)."
}

variable ssl_certificate {
  default = ""
  description = "Content of the custom SSL certificate. If this is provided, a complimentary SSL private key must also be provided."
}

variable ssl_domains {
  default = []
  description = "Specifies the domains for managed SSL certificates."
}

variable ssl_private_key {
  default = ""
  description = "Content of the custom private SSL key. If this is provided, a complimentary SSL certificate must also be provided."
}

variable target_tags {
  default = []
  description = "List of target tags for health check firewall rule."
}

variable url_map {
  default = ""
  description = "Provide a custom URL map resource to be used instead of automatically generating one."
}
