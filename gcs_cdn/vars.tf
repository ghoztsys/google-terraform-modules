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

variable bucket_location {
  default = "US"
  description = "GCS bucket location"
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
