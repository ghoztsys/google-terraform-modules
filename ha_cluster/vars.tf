variable network {
  description = "The name of the network to attach this interface to."
  default = "default"
}

variable ssh_agent {
  description = "Use `ssh-agent` to authenticate."
  default = true
}

variable ssh_user {
  description = "User to use for establishing SSH connection."
  default = "root"
}

variable app_id {
  description = "The app ID (i.e. `sybl`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instances."
  default = "sybl"
}

variable service_id {
  description = "The service ID. This is added to the name of the generated GCE instances and their tags."
}

variable "region_zone" {
  description = "The region zone where the new resources will be created in, i.e. us-central1-a. See https://cloud.google.com/compute/docs/regions-zones/."
  default = "us-central1-a"
}

variable "datacenter" {
  description = "The datacenter of this resource. This value becomes a tag."
  default = "dc0"
}

variable "environment" {
  description = "The environment of this resource, i.e. development, staging, etc. This value becomes a tag."
  default = "development"
}

variable "node_machine_type" {
  description = "The machine type of the Nomad node resources. See https://cloud.google.com/compute/docs/machine-types."
  default = "f1-micro"
}

variable "node_disk_image" {
  description = "The disk image of the Nomad node resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  default = "ubuntu-1604-xenial-v20161214"
}

variable "node_disk_type" {
  description = "The Nomad node resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable "node_count" {
  description = "The number of Nomad node resources to create."
  default = 5
}

variable "node_service_scopes" {
  description = "The service scopes of Nomad node resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable "node_tags" {
  description = "Additional tags for Nomad node resources."
  default = []
}

variable "lb_machine_type" {
  description = "The machine type of the HAProxy resources. See https://cloud.google.com/compute/docs/machine-types."
  default = "f1-micro"
}

variable "lb_disk_image" {
  description = "The disk image of the HAProxy resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  default = "ubuntu-1604-xenial-v20161214"
}

variable "lb_disk_type" {
  description = "The HAProxy resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable "lb_count" {
  description = "The number of HAProxy resources to create."
  default = 1
}

variable "lb_service_scopes" {
  description = "The service scopes of HAProxy resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable "lb_tags" {
  description = "Additional tags for HAProxy resources."
  default = []
}

variable "master_machine_type" {
  description = "The machine type of the Consul/Nomad master resources. See https://cloud.google.com/compute/docs/machine-types."
  default = "f1-micro"
}

variable "master_disk_image" {
  description = "The disk image of the Consul/Nomad master resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  default = "ubuntu-1604-xenial-v20161214"
}

variable "master_disk_type" {
  description = "The Consul/Nomad master resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable "master_count" {
  description = "The number of Consul/Nomad master resources to create."
  default = 3
}

variable "master_service_scopes" {
  description = "The service scopes of Consul/Nomad master resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/logging.write"
  ]
}

# Additional tags for Consul/Nomad master resources.
variable "master_tags" { default = [] }

variable "db_machine_type" {
  description = "The machine type of the MongoDB master resources. See https://cloud.google.com/compute/docs/machine-types."
  default = "f1-micro"
}

variable "db_disk_image" {
  description = "The disk image of the MongoDB resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  default = "ubuntu-1604-xenial-v20161214"
}

variable "db_disk_type" {
  description = "The MongoDB resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable "db_count" {
  description = "The number of MongoDB resources to create."
  default = 1
}

variable "db_service_scopes" {
  description = "The service scopes of MongoDB resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/logging.write"
  ]
}

variable "db_tags" {
  description = "Additional tags for MongoDB resources."
  default = []
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
  desdription = "Consul DNS port to open for the firewall."
  default = 8600
}

variable "mongodb_port" {
  description = "MongoDB port"
  default = 27017
}

variable "node_port_min" {
  description = "Port bottom bound of Nomad client service."
  default = 0
}

variable "node_port_max" {
  description = "Port upper bound of Nomad client service."
  default = 65535
}

variable "nomad_http_port" {
  description = "HTTP port of Nomad services."
  default = 4646
}

variable "nomad_rpc_port" {
  description = "RPC port of Nomad services."
  default = 4647
}

variable "nomad_serf_port" {
  description = "Serf port of Nomad services."
  default = 4648
}
