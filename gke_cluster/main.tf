# If enabled, generate random 6-character string to append to the cluster name.
resource "random_id" "default" {
  count = var.use_hex_suffix ? 1 : 0

  byte_length = 3

  keepers = {
    name = var.name
  }
}


# Create the Kubernetes cluster but immediately delete the default node pool.
resource "google_container_cluster" "default" {
  cluster_ipv4_cidr        = var.cluster_ipv4_cidr
  initial_node_count       = 1
  location                 = var.region_zone
  name                     = "${var.name}${var.use_hex_suffix ? "-${random_id.default[0].hex}" : ""}"
  network                  = var.network
  project                  = var.project_id
  remove_default_node_pool = true

  addons_config {
    network_policy_config {
      disabled = true
    }
  }
}

# Create separately managed node pool for the cluster. This allows node pools to
# be added and removed without recreating the cluster.
resource "google_container_node_pool" "default" {
  cluster    = google_container_cluster.default.name
  location   = var.region_zone
  name       = var.node_pool_name
  node_count = var.node_count

  node_config {
    labels          = var.labels
    machine_type    = var.machine_type
    oauth_scopes    = var.service_scopes
    service_account = var.service_account
    tags            = concat(var.tags, [var.name], values(var.labels))
  }
}

# Set named ports for the instance group URLs.
resource "google_compute_instance_group_named_port" "default" {
  group = google_container_node_pool.default.instance_group_urls[0]
  name  = var.port_name
  port  = var.port
  zone  = var.region_zone
}
