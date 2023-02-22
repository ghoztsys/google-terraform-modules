variable "app_id" {
  default     = "app"
  description = "The app ID (i.e. `app`, etc) to associate with this module. This value will be prefixed to the name of the generated GCE instance."
}

variable "datacenter" {
  default     = "dc0"
  description = "The datacenter of the new resources. This value becomes a tag and label."
}

variable "disk_image" {
  default     = "ubuntu-1604-xenial-v20161214"
  description = "The disk image of the resource. Ubuntu is preferred. You can find a list of images in your GCP console by selecting 'Images' in the 'Compute Engine' dashboard."
}

variable "disk_type" {
  default     = "pd-ssd"
  description = "The disk type (i.e. local or persistent disk, standard or ssd) as specified by `pd-standard`, `pd-ssd`, or `local-ssd`. `pd-ssd` is preferred."
}

variable "environment" {
  default     = "development"
  description = "The environment of the resources, i.e. development, staging, etc. This value becomes a tag and label."
}

variable "machine_type" {
  default     = "f1-micro"
  description = "The machine type of the resource. See https://cloud.google.com/compute/docs/machine-types."
}

variable "mongodb_port" {
  default     = 27017
  description = "MongoDB connection port."
}

variable "network" {
  default     = "default"
  description = "The name of the network to create the resources in."
}

variable "nodes" {
  default     = 1
  description = "Number of nodes to create in the cluster."
}

variable "project" {
  description = "ID of project to create resources in."
  type        = string
}

variable "region_zone" {
  default     = "us-central1-a"
  description = "The region zone where the new resources will be created in, i.e. `us-central1-a`. See https://cloud.google.com/compute/docs/regions-zones/."
}

variable "service_id" {
  description = "The service ID. This is added to the name of the generated GCE instance and its tags."
}

variable "service_scopes" {
  default = [
    "https://www.googleapis.com/auth/logging.write",
  ]
  description = "The service scopes. Both OAuth2 URLs and short names are supported. See https://developers.google.com/identity/protocols/googlescopes."
}

variable "ssh_agent" {
  default     = true
  description = "Use `ssh-agent` to authenticate."
}

variable "ssh_user" {
  default     = "root"
  description = "User to use for establishing SSH connection."
}

variable "tags" {
  default     = []
  description = "Additional tags."
}
