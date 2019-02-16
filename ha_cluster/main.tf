# This module defines a high availability cluster that runs an application,
# consisting of the following nodes: the master node(s) for controlling all
# other nodes within the cluster, the load balancer node(s) for directing
# traffic to the nodes that actually run the app, the database node(s) for
# storing data, and the application node(s) for serving the app and handling
# requests.

resource "random_id" "default" {
  byte_length = 4
  keepers {
    name = "${var.app_id}-${var.service_id}-${var.datacenter}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
    service_id = "${var.service_id}"
    datacenter = "${var.datacenter}"
    environment = "${var.environment}"
  }
}

# Create the GCE instance(s) for Consul/Nomad masters. They are responsible for
# service discoveries and orchestrating Docker containers.
resource "google_compute_instance" "master" {
  name = "gce-${random_id.default.keepers.name}-master${count.index}-${random_id.default.hex}"
  machine_type = "${var.master_machine_type}"
  zone = "${var.region_zone}"
  count = "${var.master_count}"
  tags = ["${concat(var.master_tags, list(
    "gce-${random_id.default.keepers.name}-master${count.index}-${random_id.default.hex}",
    "master",
    "ha-cluster",
    "${random_id.default.keepers.service_id}",
    "${random_id.default.keepers.environment}",
    "${random_id.default.keepers.datacenter}"
  ))}"]
  labels {
    service = "${random_id.default.keepers.service_id}"
    environment = "${random_id.default.keepers.environment}"
    datacenter = "${random_id.default.keepers.datacenter}"
  }
  boot_disk {
    initialize_params {
      image = "${var.master_disk_image}"
      type = "${var.master_disk_type}"
    }
  }
  network_interface {
    network = "${var.network}"
    access_config {} # Ephemeral IP
  }
  service_account {
    scopes = ["${var.master_service_scopes}"]
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"
    connection {
      type = "ssh"
      agent = "${var.ssh_agent}"
      user = "${var.ssh_user}"
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for Nomad nodes. These nodes will be housing all
# the orchestrated Docker app containers.
resource "google_compute_instance" "node" {
  name = "gce-${random_id.default.keepers.name}-node${count.index}-${random_id.default.hex}"
  machine_type = "${var.node_machine_type}"
  zone = "${var.region_zone}"
  count = "${var.node_count}"
  tags = ["${concat(var.node_tags, list(
    "gce-${random_id.default.keepers.name}-node${count.index}-${random_id.default.hex}",
    "node",
    "ha-cluster",
    "${random_id.default.keepers.service_id}",
    "${random_id.default.keepers.environment}",
    "${random_id.default.keepers.datacenter}"
  ))}"]
  labels {
    service = "${random_id.default.keepers.service_id}"
    environment = "${random_id.default.keepers.environment}"
    datacenter = "${random_id.default.keepers.datacenter}"
  }
  boot_disk {
    initialize_params {
      image = "${var.node_disk_image}"
      type = "${var.node_disk_type}"
    }
  }
  network_interface {
    network = "${var.network}"
    access_config {
      # Ephemeral IP
    }
  }
  service_account {
    scopes = ["${var.node_service_scopes}"]
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"
    connection {
      type = "ssh"
      agent = "${var.ssh_agent}"
      user = "${var.ssh_user}"
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for MongoDB.
resource "google_compute_instance" "db" {
  name = "gce-${random_id.default.keepers.name}-db${count.index}-${random_id.default.hex}"
  machine_type = "${var.db_machine_type}"
  zone = "${var.region_zone}"
  count = "${var.db_count}"
  tags = ["${concat(var.db_tags, list(
    "gce-${random_id.default.keepers.name}-db${count.index}-${random_id.default.hex}",
    "db",
    "ha-cluster",
    "${random_id.default.keepers.service_id}",
    "${random_id.default.keepers.environment}",
    "${random_id.default.keepers.datacenter}"
  ))}"]
  labels {
    service = "${random_id.default.keepers.service_id}"
    environment = "${random_id.default.keepers.environment}"
    datacenter = "${random_id.default.keepers.datacenter}"
  }
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
      type = "${var.db_disk_type}"
    }
  }
  network_interface {
    network = "${var.network}"
    access_config {} # Ephemeral IP
  }
  service_account {
    scopes = ["${var.db_service_scopes}"]
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"
    connection {
      type = "ssh"
      agent = "${var.ssh_agent}"
      user = "${var.ssh_user}"
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for HAProxy load balancing.
resource "google_compute_instance" "lb" {
  name = "gce-${random_id.default.keepers.name}-lb${count.index}-${random_id.default.hex}"
  machine_type = "${var.lb_machine_type}"
  zone = "${var.region_zone}"
  count = "${var.lb_count}"
  tags = ["${concat(var.lb_tags, list(
    "gce-${random_id.default.keepers.name}-lb${count.index}-${random_id.default.hex}",
    "lb",
    "ha-cluster",
    "${random_id.default.keepers.service_id}",
    "${random_id.default.keepers.environment}",
    "${random_id.default.keepers.datacenter}"
  ))}"]
  labels {
    service = "${random_id.default.keepers.service_id}"
    environment = "${random_id.default.keepers.environment}"
    datacenter = "${random_id.default.keepers.datacenter}"
  }
  boot_disk {
    initialize_params {
      image = "${var.lb_disk_image}"
      type = "${var.lb_disk_type}"
    }
  }
  network_interface {
    network = "${var.network}"
    access_config {
      # Ephemeral IP
    }
  }
  service_account {
    scopes = ["${var.lb_service_scopes}"]
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"
    connection {
      type = "ssh"
      agent = "${var.ssh_agent}"
      user = "${var.ssh_user}"
      timeout = "5m"
    }
  }
}

# Create firewall rules WWW access.
resource "google_compute_firewall" "www" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-www"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "${var.http_port}",
      "${var.https_port}",
    ]
  }
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = ["${google_compute_instance.lb.*.name}"]
}

# Create firewall rules for HAProxy stats access.
resource "google_compute_firewall" "haproxy" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-haproxy"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "${var.haproxy_stats_port}",
    ]
  }
  source_tags = ["${google_compute_instance.lb.*.name}"]
  target_tags = ["${google_compute_instance.lb.*.name}"]
}

# Create firewall rules for Nomad node access.
resource "google_compute_firewall" "node" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-node"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
  source_tags = ["${google_compute_instance.lb.*.name}"]
  target_tags = ["${google_compute_instance.node.*.name}"]
}

# Create firewall rules for Consul discovery.
resource "google_compute_firewall" "consul" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-consul"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "0-65535",
    ]
  }
  source_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name, google_compute_instance.db.*.name, google_compute_instance.lb.*.name)}"]
  target_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name, google_compute_instance.db.*.name, google_compute_instance.lb.*.name)}"]
}

# Create firewall rules for Nomad discovery.
resource "google_compute_firewall" "nomad" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-nomad"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
  source_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name)}"]
  target_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name)}"]
}

# Create firewall rules for MongoDB access.
resource "google_compute_firewall" "mongodb" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-mongodb"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "${var.mongodb_port}",
    ]
  }
  source_tags = ["${google_compute_instance.node.*.name}"]
  target_tags = ["${google_compute_instance.db.*.name}"]
}

# Create common firewall rules for external access to all generated GCE
# instances.
resource "google_compute_firewall" "external" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-external"
  network = "${var.network}"
  priority = 1000
  allow { # Allow RDP from anywhere.
    protocol = "tcp"
    ports = [
      "3389",
    ]
  }
  allow { # Allow ICMP from anywhere.
    protocol = "icmp"
  }
  allow { # Allow SSH from anywhere.
    protocol = "tcp"
    ports = [
      "22",
    ]
  }
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name, google_compute_instance.db.*.name, google_compute_instance.lb.*.name)}"]
}

# Create common firewall rules for internal access to all generated GCE
# instances.
resource "google_compute_firewall" "internal" {
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}-internal"
  network = "${var.network}"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "0-65535",
    ]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = [
    "10.128.0.0/9",
  ]
  target_tags = ["${concat(google_compute_instance.master.*.name, google_compute_instance.node.*.name, google_compute_instance.db.*.name, google_compute_instance.lb.*.name)}"]
}
