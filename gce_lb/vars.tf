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

variable backend_services {
  description = "Map backend service indices to list of backend maps."
  type = "map"
}

variable backend_service_params {
  description = "Comma-separated encoded list of parameters in order: health check path, service port name, service port, backend timeout seconds."
  type = "list"
  default = []
}

variable backend_bucket_params {
  description = "Comma-separated encoded list of parameters in order: url map pathname, bucket name, location."
  type = "list"
  default = []
}

variable backend_protocol {
  description = "The protocol with which to talk to the backend service."
  default = "HTTP"
}

variable private_key {
  description = "Content of the private SSL key."
  default = ""
}

variable certificate {
  description = "Content of the SSL certificate."
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

variable target_tags {
  description = "List of target tags for health check firewall rule."
  type = "list"
  default = []
}
