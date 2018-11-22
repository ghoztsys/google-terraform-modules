resource "random_id" "default" {
  keepers {
    name = "${var.app_id}-${var.service_id}-${var.datacenter}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
    service_id = "${var.service_id}"
    datacenter = "${var.datacenter}"
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

  node_config {
    machine_type = "${var.machine_type}"
    oauth_scopes = ["${var.service_scopes}"]

    tags = ["${concat(var.tags, list(
      "${random_id.default.keepers.name}-${random_id.default.hex}-cluster",
      "${random_id.default.keepers.service_id}",
      "${random_id.default.keepers.environment}",
      "${random_id.default.keepers.datacenter}"
    ))}"]

    labels {
      service = "${random_id.default.keepers.service_id}"
      environment = "${random_id.default.keepers.environment}"
      datacenter = "${random_id.default.keepers.datacenter}"
    }
  }
}
