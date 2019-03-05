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

variable bucket_location {
  description = "GCS bucket location"
  default = "US"
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
