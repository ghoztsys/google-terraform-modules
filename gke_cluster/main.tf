provider "google" {
  project = var.project_id
  region = var.region
  version = "~> 2.13"
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
    command = "gcloud compute instance-groups set-named-ports ${google_container_cluster.default.instance_group_urls[0]} --named-ports=${var.node_port_name}:${var.node_port}"
  }
}

# Create namespace for default service.
resource "kubernetes_namespace" "default" {
  count = (var.namespace == "" || var.namespace == "default") ? 0 : 1

  metadata {
    name = var.namespace
  }
}

# Create default NodePort service.
resource "kubernetes_service" "default" {
  metadata {
    name = var.service_name
    namespace = kubernetes_namespace.default[0].metadata[0].name
  }

  spec {
    selector = {
      name = var.service_name
    }
    type = "NodePort"

    port {
      name = var.node_port_name
      node_port = var.node_port
      port = var.cluster_internal_port
      protocol = "TCP"
    }
  }
}

# Create firewall for NodePort service (if specified).
resource "google_compute_firewall" "default" {
  count = var.expose_node_port ? 1 : 0
  name = "${google_container_cluster.default.name}-service-port"
  network = var.network
  priority = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = [
    google_container_cluster.default.name,
  ]

  allow {
    protocol = "tcp"
    ports = [
      var.node_port,
    ]
  }
}
