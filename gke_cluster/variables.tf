variable "cluster_ipv4_cidr" {
  default     = null
  description = "The IP address range of the kubernetes pods in this cluster. Default is an automatically assigned CIDR."
  nullable    = true
  type        = string
}

variable "disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the resource. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
  type        = string
}

variable "disk_type" {
  default     = "pd-ssd"
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by`pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
  type        = string
}

variable "enable_workload_identity" {
  default     = false
  description = "Specifies if Workload Identity should be enabled for the cluster."
  type        = bool
}

variable "labels" {
  description = "Labels (key/value pair) to be added to each node. The value of each label will also be added as tags."
  type        = map(string)
}

variable "machine_type" {
  default     = "g1-small"
  description = "The machine type of the resource. See https://cloud.google.com/compute/docs/machine-types."
  type        = string
}

variable "name" {
  default     = "cluster"
  description = "Name of the GKE cluster."
  type        = string
}

variable "network" {
  default     = "default"
  description = "The name of the network to attach this interface to."
  type        = string
}

variable "node_count" {
  default     = 1
  description = "The initial number of nodes to create for this Kubernetes cluster."
  type        = number

  validation {
    condition     = var.node_count % 2 != 0
    error_message = "node_count must be an odd number."
  }
}

variable "node_pool_name" {
  default     = "node-pool"
  description = "Name of the node pool."
  type        = string
}

variable "port" {
  default     = 30000
  description = "Port in the K8s cluster that is exposed to the external network."
  type        = number
}

variable "port_name" {
  default     = "http"
  description = "Name of the port in the K8s cluster that is exposed to the external network."
  type        = string
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "region_zone" {
  description = "The region zone where the new resources will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
  type        = string
}

variable "service_account" {
  default     = null
  description = "The service account to assign to the cluster nodes."
  type        = string
}

variable "service_scopes" {
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/devstorage.read_write",
  ]
  description = "The service scopes. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
  type        = list(string)
}

variable "tags" {
  default     = []
  description = "Additional tags to add to each node."
  type        = list(string)
}

variable "use_hex_suffix" {
  default     = true
  description = "Specifies if 6-character hex suffix should be appended to the cluster name."
  type        = bool
}
