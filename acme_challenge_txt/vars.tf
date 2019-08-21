variable dns_name {
  description = "The target DNS name, i.e. `sybl.io.`"
}

variable dns_managed_zone {
  description = "The name of the DNS managed zone."
}

variable subdomain {
  default = ""
  description = "The subdomain, i.e. `api`. Leave blank if this is not a subdomain."
}

variable value {
  description = "The TXT record value."
}
