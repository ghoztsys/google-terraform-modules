variable ip_version {
  description = "IP version for the global address (IPv4 or v6), empty defaults to IPV4"
  default = ""
}

variable name {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable backends {
  description = "Map backend indices to list of backend maps."
  type = "map"
}

variable backend_params {
  description = "Comma-separated encoded list of parameters in order: health check path, service port name, service port, backend timeout seconds."
  type = "list"
}

variable backend_protocol {
  description = "The protocol with which to talk to the backend service."
  default = "HTTP"
}

variable create_url_map {
  description = "Set to `false` if url_map variable is provided."
  default = true
}

variable url_map {
  description = "The url_map resource to use. Default is to send all traffic to first backend."
  default = ""
}

variable private_key {
  description = "Content of the private SSL key."
}

variable certificate {
  description = "Content of the SSL certificate."
}

variable security_policy {
  description = "The resource URL for the security policy to associate with the backend service."
  default = ""
}

variable cdn {
  description = "Set to `true` to enable cdn on backend."
  default = false
}

variable target_tags {
  description = "List of target tags for health check firewall rule."
  type = "list"
}
