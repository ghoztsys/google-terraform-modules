# This module defines a single GCE instance that contains all the services
# required to run an application (i.e. master, load balancer, database).

terraform {
  required_version = ">= 0.12.24"

  required_providers {
    google = ">= 2.20.3"
  }
}

# Generate random ID to be used for naming the created cloud resources.
module "uuid" {
  basename = "${var.app_id}-${var.service_id}-${var.datacenter}"
  environment = var.environment
  source = "../uuid"
}

resource "google_compute_instance" "default" {
  machine_type = var.machine_type
  name = "${module.uuid.value}-sandbox"
  tags = concat(var.tags, list(
    "${module.uuid.value}-sandbox",
    "sandbox",
    var.service_id,
    var.environment,
    var.datacenter,
  ))
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.disk_image
      type = var.disk_type
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
    scopes = var.service_scopes
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

resource "google_compute_firewall" "external" {
  name = "${google_compute_instance.default.name}-external"
  network = var.network
  priority = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = [
    google_compute_instance.default.name,
  ]

  allow { # Allow access to HTTP/HTTPS, HAProxy stats and Consul endpoints from anywhere.
    protocol = "tcp"
    ports = [
      var.http_port,
      var.https_port,
      var.haproxy_stats_port,
      var.consul_http_port,
      var.consul_dns_port,
    ]
  }

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

resource "google_compute_firewall" "internal" {
  name = "${google_compute_instance.default.name}-internal"
  network = var.network
  priority = 1000
  source_ranges = [
    "10.128.0.0/9",
  ]
  target_tags = [
    google_compute_instance.default.name,
  ]

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
