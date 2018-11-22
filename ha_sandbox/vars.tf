variable app_id {
  description = "The app ID (i.e. `sybl`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
  default = "sybl"
}

variable service_id {
  description = "The service ID. This is added to the name of the generated GCE instance and its tags."
}

variable region_zone {
  description = "The region zone where the new GCE instance will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
  default = "us-central1-a"
}

variable datacenter {
  description = "The datacenter of the GCE instance. This value becomes a tag and label."
  default = "dc0"
}

variable environment {
  description = "The environment of the GCE instance, i.e. development, staging, etc. This value becomes a tag and label."
  default = "development"
}

variable machine_type {
  description = "The machine type of the GCE instance. See https://cloud.google.com/compute/docs/machine-types."
  default = "g1-small"
}

variable disk_image {
  description = "The disk image of the GCE instance. Ubuntu is preferred. See https://console.cloud.google.com/compute/images."
  default = "ubuntu-1604-xenial-v20161214"
}

variable disk_type {
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable tags {
  description = "Additional tags for the GCE instance."
  default = []
}

variable service_scopes {
  description = "The service scopes of the GCE instance. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable network {
  description = "The name of the network to the created GCE instance and firewall to."
  default = "default"
}

variable ssh_agent {
  description = "Use `ssh-agent` to authenticate when running the remote provisioner for the GCE instance."
  default = true
}

variable ssh_user {
  description = "User to use for establishing SSH connection when running the remote provisioner for the GCE instance."
  default = "root"
}

variable "http_port" {
  description = "HTTP port to open for the firewall."
  default = 80
}

variable "https_port" {
  description = "HTTPS port to open for the firewall."
  default = 443
}

variable "haproxy_stats_port" {
  description = "HAProxy stats port to open for the firewall."
  default = 1936
}

variable "consul_http_port" {
  description = "Consul HTTP port to open for the firewall."
  default = 8500
}

variable "consul_dns_port" {
  description = "Consul DNS port to open for the firewall."
  default = 8600
}
