provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

resource "random_id" "default" {
  keepers {
    name = "${var.app_id}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
    app_id = "${var.app_id}"
    environment = "${var.environment}"
  }

  byte_length = 4
}

resource "google_container_cluster" "default" {
  name = "${random_id.default.keepers.name}-${random_id.default.hex}-cluster"
  zone = "${var.region_zone}"
  initial_node_count = "${var.node_count}"
  network = "${var.network}"
  cluster_ipv4_cidr = "${var.cluster_ipv4_cidr}"

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  master_auth {
    username = "${var.auth_username}"
    password = "${var.auth_password}"
  }

  node_config {
    machine_type = "${var.machine_type}"
    oauth_scopes = ["${var.service_scopes}"]

    tags = ["${concat(var.tags, list(
      "${random_id.default.keepers.name}-${random_id.default.hex}-cluster",
      "${random_id.default.keepers.app_id}",
      "${random_id.default.keepers.environment}",
    ))}"]

    labels {
      service = "${random_id.default.keepers.app_id}"
      environment = "${random_id.default.keepers.environment}"
    }
  }
}

resource "google_compute_firewall" "default" {
  name = "${google_container_cluster.default.name}-node-port"
  network = "${var.network}"
  priority = 1000
  count = "${var.expose_node_port ? 1 : 0}"

  # Allow NodePort from anywhere.
  allow {
    protocol = "tcp"
    ports = ["${var.node_port}"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${google_container_cluster.default.name}"]
}

# Outputs.
output "instance_group_urls" {
  description = "URL of provisioned instance groups."
  value = "${module.cluster0.instance_group_urls}"
}
