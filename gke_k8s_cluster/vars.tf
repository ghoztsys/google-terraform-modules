variable app_id {
  description = "The app ID (i.e. `sybl`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
}

variable region_zone {
  description = "The region zone where the new resources will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
  default = "us-central1-a"
}

variable environment {
  description = "The environment of the resources, i.e. development, staging, etc. This value becomes a tag and label."
  default = "development"
}

variable node_count {
  description = "The initial number of nodes to create for this Kubernetes cluster."
  default = 3
}

variable node_port {
  description = "Specify the node port (30000-32767) to indicate that node port is being used"
  default = 30000
}

variable expose_node_port {
  description = "Specify whether the node port should be open to the public"
  default = false
}

variable machine_type {
  description = "The machine type of the resource. See https://cloud.google.com/compute/docs/machine-types."
  default = "g1-small"
}

variable disk_image {
  description = "The disk image of the resource. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  default = "ubuntu-1604-xenial-v20161214"
}

variable disk_type {
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by`pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  default = "pd-ssd"
}

variable tags {
  description = "Additional tags."
  default = []
}

variable service_scopes {
  description = "The service scopes. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/devstorage.read_write"
  ]
}

variable cluster_ipv4_cidr {
  description = "The IP address range of the kubernetes pods in this cluster. Default is an automatically assigned CIDR."
  default = ""
}

variable network {
  description = "The name of the network to attach this interface to."
  default = "default"
}

variable "auth_username" {
  description = "Username for authenticating and accessing the Kubernetes cluster."
  default = "admin"
}

variable "auth_password" {
  description = "Password for authenticating and accessing the Kubernetes cluster"
}
