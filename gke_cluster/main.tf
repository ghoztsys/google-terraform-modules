provider "google" {
  project = var.project_id
  region = var.region
  version = "~> 2.13"
}

provider "random" {
  version = "~> 2.2"
}

provider "null" {
  version = "~> 2.1"
}

# Generate random ID to be used for naming the created cloud resources.
resource "random_id" "default" {
  byte_length = 4
  keepers = {
    app_id = var.app_id
    environment = var.environment
    name = "${var.app_id}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}

# Generate random password used for connecting to the Kubernetes cluster.
resource "random_id" "password" {
  byte_length = 8
  count = var.auth_password == "" ? 1 : 0
  keepers = {
    name = random_id.default.hex
  }
}

# Create the Kubernetes cluster.
resource "google_container_cluster" "default" {
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  initial_node_count = var.node_count
  location = var.region_zone
  name = "${random_id.default.keepers.name}-${random_id.default.hex}-cluster"
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
      "${random_id.default.keepers.name}-${random_id.default.hex}-cluster",
      random_id.default.keepers.app_id,
      random_id.default.keepers.environment,
    ))
    labels = {
      service = random_id.default.keepers.app_id
      environment = random_id.default.keepers.environment
    }
  }
}

# Set named ports for created instance group.
resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "gcloud compute instance-groups set-named-ports ${google_container_cluster.default.instance_group_urls[0]} --named-ports=${var.port_name}:${var.port}"
  }
}
