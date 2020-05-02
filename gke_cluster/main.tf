terraform {
  required_version = ">= 0.12.24"

  required_providers {
    google = ">= 2.20.3"
    kubernetes = ">= 1.9"
  }
}

provider "kubernetes" {
  client_certificate = base64decode(google_container_cluster.default.master_auth[0].client_certificate)
  client_key = base64decode(google_container_cluster.default.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)
  host = google_container_cluster.default.endpoint
  password = var.auth_password == "" ? random_id.password[0].hex : var.auth_password
  username = var.auth_username
  version = "~> 1.9"
}

# Generate random ID to be used for naming the created cloud resources.
module "uuid" {
  basename = var.app_id
  environment = var.environment
  source = "../uuid"
}

# Generate random password used for connecting to the Kubernetes cluster.
resource "random_id" "password" {
  byte_length = 8
  count = var.auth_password == "" ? 1 : 0
  keepers = {
    name = module.uuid.value
  }
}

# Create the Kubernetes cluster.
resource "google_container_cluster" "default" {
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  initial_node_count = var.node_count
  location = var.region_zone
  name = "${module.uuid.value}-cluster"
  network = var.network

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  master_auth {
    username = var.auth_username
    password = var.auth_password == "" ? random_id.password[0].hex : var.auth_password
  }

  node_config {
    machine_type = var.machine_type
    oauth_scopes = var.service_scopes
    tags = concat(var.tags, list(
      "${module.uuid.value}-cluster",
      var.app_id,
      var.environment,
    ))
    labels = {
      service = var.app_id
      environment = var.environment
    }
  }
}

# Set named ports for created instance group.
resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "gcloud compute instance-groups set-named-ports ${google_container_cluster.default.instance_group_urls[0]} --named-ports=${var.port_name}:${var.port}"
  }
}
