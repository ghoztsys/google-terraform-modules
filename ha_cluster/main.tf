# This module defines a high availability cluster that runs an application,
# consisting of the following nodes: the master node(s) for controlling all
# other nodes within the cluster, the load balancer node(s) for directing
# traffic to the nodes that actually run the app, the database node(s) for
# storing data, and the application node(s) for serving the app and handling
# requests.

terraform {
  required_version = ">= 0.12.24"

  required_providers {
    google = ">= 3.19.0"
  }
}

# Generate random ID to be used for naming the created cloud resources.
module "uuid" {
  basename = "${var.app_id}-${var.service_id}-${var.datacenter}"
  environment = var.environment
  source = "../uuid"
}

# Create the GCE instance(s) for Consul/Nomad masters. They are responsible for
# service discoveries and orchestrating Docker containers.
resource "google_compute_instance" "master" {
  count = var.master_count
  machine_type = var.master_machine_type
  name = "${module.uuid.value}-master${count.index}"
  tags = concat(var.master_tags, list(
    "${module.uuid.value}-master${count.index}",
    "master",
    "ha-cluster",
    var.service_id,
    var.environment,
    var.datacenter,
  ))
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.master_disk_image
      type = var.master_disk_type
    }
  }

  labels {
    service = var.service_id
    environment = var.environment
    datacenter = var.datacenter
  }

  network_interface {
    network = var.network
    access_config {} # Ephemeral IP
  }

  service_account {
    scopes = var.master_service_scopes
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"

    connection {
      type = "ssh"
      agent = var.ssh_agent
      user = var.ssh_user
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for Nomad nodes. These nodes will be housing all
# the orchestrated Docker app containers.
resource "google_compute_instance" "node" {
  count = var.node_count
  machine_type = var.node_machine_type
  name = "${module.uuid.value}-node${count.index}"
  tags = concat(var.node_tags, list(
    "${module.uuid.value}-node${count.index}",
    "node",
    "ha-cluster",
    var.service_id,
    var.environment,
    var.datacenter,
  ))
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.node_disk_image
      type = var.node_disk_type
    }
  }

  labels {
    service = var.service_id
    environment = var.environment
    datacenter = var.datacenter
  }

  network_interface {
    network = var.network
    access_config {} # Ephemeral IP
  }

  service_account {
    scopes = var.node_service_scopes
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"

    connection {
      type = "ssh"
      agent = var.ssh_agent
      user = var.ssh_user
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for MongoDB.
resource "google_compute_instance" "db" {
  count = var.db_count
  machine_type = var.db_machine_type
  name = "${module.uuid.value}-db${count.index}"
  tags = concat(var.db_tags, list(
    "${module.uuid.value}-db${count.index}",
    "db",
    "ha-cluster",
    var.service_id,
    var.environment,
    var.datacenter,
  ))
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.db_disk_image
      type = var.db_disk_type
    }
  }

  labels {
    service = var.service_id
    environment = var.environment
    datacenter = var.datacenter
  }

  network_interface {
    network = var.network
    access_config {} # Ephemeral IP
  }

  service_account {
    scopes = var.db_service_scopes
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"

    connection {
      type = "ssh"
      agent = var.ssh_agent
      user = var.ssh_user
      timeout = "5m"
    }
  }
}

# Create the GCE instance(s) for HAProxy load balancing.
resource "google_compute_instance" "lb" {
  count = var.lb_count
  machine_type = var.lb_machine_type
  name = "${module.uuid.value}-lb${count.index}"
  tags = concat(var.lb_tags, list(
    "${module.uuid.value}-lb${count.index}",
    "lb",
    "ha-cluster",
    var.service_id,
    var.environment,
    var.datacenter,
  ))
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.lb_disk_image
      type = var.lb_disk_type
    }
  }

  labels {
    service = var.service_id
    environment = var.environment
    datacenter = var.datacenter
  }

  network_interface {
    network = var.network
    access_config {} # Ephemeral IP
  }

  service_account {
    scopes = var.lb_service_scopes
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_instance"

    connection {
      type = "ssh"
      agent = var.ssh_agent
      user = var.ssh_user
      timeout = "5m"
    }
  }
}

# Create firewall rules WWW access.
resource "google_compute_firewall" "www" {
  name = "${module.uuid.value}-www"
  network = var.network
  priority = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = google_compute_instance.lb[*].name

  allow {
    protocol = "tcp"
    ports = [
      var.http_port,
      var.https_port,
    ]
  }
}

# Create firewall rules for HAProxy stats access.
resource "google_compute_firewall" "haproxy" {
  name = "${module.uuid.value}-haproxy"
  network = var.network
  priority = 1000
  source_tags = google_compute_instance.lb[*].name
  target_tags = google_compute_instance.lb[*].name

  allow {
    protocol = "tcp"
    ports = [
      var.haproxy_stats_port,
    ]
  }
}

# Create firewall rules for Nomad node access.
resource "google_compute_firewall" "node" {
  name = "${module.uuid.value}-node"
  network = var.network
  priority = 1000
  source_tags = google_compute_instance.lb[*].name
  target_tags = google_compute_instance.node[*].name

  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
}

# Create firewall rules for Consul discovery.
resource "google_compute_firewall" "consul" {
  name = "${module.uuid.value}-consul"
  network = var.network
  priority = 1000
  source_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name, google_compute_instance.db[*].name, google_compute_instance.lb[*].name)
  target_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name, google_compute_instance.db[*].name, google_compute_instance.lb[*].name)

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
}

# Create firewall rules for Nomad discovery.
resource "google_compute_firewall" "nomad" {
  name = "${module.uuid.value}-nomad"
  network = var.network
  priority = 1000
  source_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name)
  target_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name)

  allow {
    protocol = "tcp"
    ports = [
      "0-65535",
    ]
  }
}

# Create firewall rules for MongoDB access.
resource "google_compute_firewall" "mongodb" {
  name = "${module.uuid.value}-mongodb"
  network = var.network
  priority = 1000
  source_tags = google_compute_instance.node[*].name
  target_tags = google_compute_instance.db[*].name

  allow {
    protocol = "tcp"
    ports = [
      var.mongodb_port,
    ]
  }
}

# Create common firewall rules for external access to all generated GCE
# instances.
resource "google_compute_firewall" "external" {
  name = "${module.uuid.value}-external"
  network = var.network
  priority = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name, google_compute_instance.db[*].name, google_compute_instance.lb[*].name)

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
}

# Create common firewall rules for internal access to all generated GCE
# instances.
resource "google_compute_firewall" "internal" {
  name = "${module.uuid.value}-internal"
  network = var.network
  priority = 1000
  source_ranges = [
    "10.128.0.0/9",
  ]
  target_tags = concat(google_compute_instance.master[*].name, google_compute_instance.node[*].name, google_compute_instance.db[*].name, google_compute_instance.lb[*].name)

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
}
