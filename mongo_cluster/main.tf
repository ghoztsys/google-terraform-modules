# Generate random ID to be used for naming the created cloud resources.
module "resource_id" {
  basename    = "${var.app_id}-${var.service_id}-${var.datacenter}"
  environment = var.environment
  source      = "../resource_id"
}

resource "google_compute_instance" "default" {
  count        = var.nodes
  machine_type = var.machine_type
  name         = "${module.resource_id.value}-db${count.index}"
  project      = var.project_id
  tags = concat(var.tags, [
    "${module.resource_id.value}-db${count.index}",
    "db",
    var.service_id,
    var.environment,
    var.datacenter,
  ])
  zone = var.region_zone

  boot_disk {
    initialize_params {
      image = var.disk_image
      type  = var.disk_type
    }
  }

  labels {
    service     = var.service_id
    environment = var.environment
    datacenter  = var.datacenter
    index       = count.index
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
      type    = "ssh"
      agent   = var.ssh_agent
      user    = var.ssh_user
      timeout = "5m"
    }
  }
}

resource "google_compute_firewall" "external" {
  name     = "${google_compute_instance.default.name}-external"
  network  = var.network
  priority = 1000
  project  = var.project_id
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = google_compute_instance.default[*].name

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
  name     = "${google_compute_instance.default.name}-internal"
  network  = var.network
  priority = 1000
  project  = var.project_id
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
