variable "project_id" {
  description = "ID of project to create resources in."
  type        = string
}

variable "app_id" {
  default     = "app"
  description = "The app ID (i.e. `app`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instances."
}

variable "consul_dns_port" {
  default     = 8600
  desdription = "Consul DNS port to open for the firewall."
}

variable "consul_http_port" {
  default     = 8500
  description = "Consul HTTP port to open for the firewall."
}

variable "datacenter" {
  default     = "dc0"
  description = "The datacenter of this resource. This value becomes a tag."
}

variable "db_count" {
  default     = 1
  description = "The number of MongoDB resources to create."
}

variable "db_disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the MongoDB resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable "db_disk_type" {
  default     = "pd-ssd"
  description = "The MongoDB resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable "db_machine_type" {
  default     = "f1-micro"
  description = "The machine type of the MongoDB master resources. See https://cloud.google.com/compute/docs/machine-types."
}

variable "db_service_scopes" {
  default = [
    "https://www.googleapis.com/auth/logging.write",
  ]
  description = "The service scopes of MongoDB resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable "db_tags" {
  default     = []
  description = "Additional tags for MongoDB resources."
}

variable "environment" {
  default     = "development"
  description = "The environment of this resource, i.e. development, staging, etc. This value becomes a tag."
}

variable "haproxy_stats_port" {
  default     = 1936
  description = "HAProxy stats port to open for the firewall."
}

variable "http_port" {
  default     = 80
  description = "HTTP port to open for the firewall."
}

variable "https_port" {
  default     = 443
  description = "HTTPS port to open for the firewall."
}

variable "lb_count" {
  default     = 1
  description = "The number of HAProxy resources to create."
}

variable "lb_disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the HAProxy resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable "lb_disk_type" {
  default     = "pd-ssd"
  description = "The HAProxy resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable "lb_machine_type" {
  default     = "f1-micro"
  description = "The machine type of the HAProxy resources. See https://cloud.google.com/compute/docs/machine-types."
}

variable "lb_service_scopes" {
  default = [
    "https://www.googleapis.com/auth/logging.write"
  ]
  description = "The service scopes of HAProxy resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable "lb_tags" {
  default     = []
  description = "Additional tags for HAProxy resources."
}

variable "master_count" {
  default     = 3
  description = "The number of Consul/Nomad master resources to create."
}

variable "master_disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the Consul/Nomad master resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable "master_disk_type" {
  default     = "pd-ssd"
  description = "The Consul/Nomad master resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable "master_machine_type" {
  default     = "f1-micro"
  description = "The machine type of the Consul/Nomad master resources. See https://cloud.google.com/compute/docs/machine-types."
}

variable "master_service_scopes" {
  default = [
    "https://www.googleapis.com/auth/logging.write",
  ]
  description = "The service scopes of Consul/Nomad master resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable "master_tags" {
  default     = []
  description = "Additional tags for Consul/Nomad master resources."
}

variable "mongodb_port" {
  default     = 27017
  description = "MongoDB port"
}

variable "node_port_max" {
  default     = 65535
  description = "Port upper bound of Nomad client service."
}

variable "node_port_min" {
  default     = 0
  description = "Port bottom bound of Nomad client service."
}

variable "nomad_http_port" {
  default     = 4646
  description = "HTTP port of Nomad services."
}

variable "nomad_rpc_port" {
  default     = 4647
  description = "RPC port of Nomad services."
}

variable "nomad_serf_port" {
  default     = 4648
  description = "Serf port of Nomad services."
}

variable "network" {
  default     = "default"
  description = "The name of the network to attach this interface to."
}

variable "node_count" {
  default     = 5
  description = "The number of Nomad node resources to create."
}

variable "node_disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the Nomad node resources. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable "node_disk_type" {
  default     = "pd-ssd"
  description = "The Nomad node resource disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable "node_machine_type" {
  default     = "f1-micro"
  description = "The machine type of the Nomad node resources. See https://cloud.google.com/compute/docs/machine-types."
}

variable "node_service_scopes" {
  default = [
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write"
  ]
  description = "The service scopes of Nomad node resources. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable "node_tags" {
  default     = []
  description = "Additional tags for Nomad node resources."
}

variable "region_zone" {
  default     = "us-central1-a"
  description = "The region zone where the new resources will be created in, i.e. us-central1-a. See https://cloud.google.com/compute/docs/regions-zones/."
}

variable "service_id" {
  description = "The service ID. This is added to the name of the generated GCE instances and their tags."
}

variable "ssh_agent" {
  default     = true
  description = "Use `ssh-agent` to authenticate."
}

variable "ssh_user" {
  default     = "root"
  description = "User to use for establishing SSH connection."
}
