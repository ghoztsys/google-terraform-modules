variable project_id {
  description = "Google Cloud Platform project ID."
}

variable app_id {
  description = "The app ID (i.e. `sybl-core`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
}

variable region {
  description = "The region where the project resides."
}

variable region_zone {
  description = "The region zone where the new resources will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
}

variable environment {
  default = "development"
  description = "The environment of the resources, i.e. development, staging, etc. This value becomes a tag and label."
}

variable namespace {
  default = "default"
  description = "Namespace to include default service"
}

variable node_count {
  default = 1
  description = "The initial number of nodes to create for this Kubernetes cluster."
}

variable service_name {
  default = "default"
  description = "Name of the default NodePort service."
}

variable service_port {
  default = 30000
  description = "Node port (30000-32767) to open."
}

variable service_port_name {
  default = "http"
  description = "Name of the opened node port."
}

variable target_port {
  default = 8080
  description = "Target port for the default NodePort service."
}

variable host_port {
  default = 80
  description = "Host port for the default NodePort service."
}

variable expose_service_port {
  default = false
  description = "Specifies whether the node port should be exposed to the public."
}

variable machine_type {
  default = "g1-small"
  description = "The machine type of the resource. See https://cloud.google.com/compute/docs/machine-types."
}

variable disk_image {
  default = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the resource. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable disk_type {
  default = "pd-ssd"
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by`pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable tags {
  default = []
  description = "Additional tags."
}

variable service_scopes {
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/devstorage.read_write"
  ]
  description = "The service scopes. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable cluster_ipv4_cidr {
  default = ""
  description = "The IP address range of the kubernetes pods in this cluster. Default is an automatically assigned CIDR."
}

variable network {
  default = "default"
  description = "The name of the network to attach this interface to."
}

variable "auth_username" {
  default = "admin"
  description = "Username for authenticating and accessing the Kubernetes cluster."
}

variable "auth_password" {
  default = ""
  description = "Password for authenticating and accessing the Kubernetes cluster"
}
