variable name {
  description = "The name of this module."
  type = string
}

variable region {
  description = "The region where the project resides."
  type = string
}

variable no_auth {
  default = true
  description = "Specifies if unauthenticated invocations are allowed. This is required if you are using an external load balancer"
  type = bool
}

variable tag {
  default = null
  description = "Cloud Run tag to provide additional fine-grained traffic routing information. See google_compute_region_network_endpoint_group#cloud_run#tag (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group)."
  type = string
}
