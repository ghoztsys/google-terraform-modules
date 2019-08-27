variable app_id {
  default = "sybl"
  description = "The app ID (i.e. `sybl`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
}

variable consul_dns_port {
  default = 8600
  description = "Consul DNS port to open for the firewall."
}

variable consul_http_port {
  default = 8500
  description = "Consul HTTP port to open for the firewall."
}

variable datacenter {
  default = "dc0"
  description = "The datacenter of the GCE instance. This value becomes a tag and label."
}

variable disk_image {
  default = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the GCE instance. Ubuntu is preferred. See https://console.cloud.google.com/compute/images."
}

variable disk_type {
  default = "pd-ssd"
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable environment {
  default = "development"
  description = "The environment of the GCE instance, i.e. development, staging, etc. This value becomes a tag and label."
}

variable haproxy_stats_port {
  default = 1936
  description = "HAProxy stats port to open for the firewall."
}

variable http_port {
  default = 80
  description = "HTTP port to open for the firewall."
}

variable https_port {
  default = 443
  description = "HTTPS port to open for the firewall."
}

variable machine_type {
  default = "g1-small"
  description = "The machine type of the GCE instance. See https://cloud.google.com/compute/docs/machine-types."
}

variable network {
  default = "default"
  description = "The name of the network to the created GCE instance and firewall to."
}

variable region_zone {
  default = "us-central1-a"
  description = "The region zone where the new GCE instance will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
}

variable service_id {
  description = "The service ID. This is added to the name of the generated GCE instance and its tags."
}

variable service_scopes {
  default = [
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write",
  ]
  description = "The service scopes of the GCE instance. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable ssh_agent {
  default = true
  description = "Use `ssh-agent` to authenticate when running the remote provisioner for the GCE instance."
}

variable ssh_user {
  default = "root"
  description = "User to use for establishing SSH connection when running the remote provisioner for the GCE instance."
}

variable tags {
  default = []
  description = "Additional tags for the GCE instance."
}
