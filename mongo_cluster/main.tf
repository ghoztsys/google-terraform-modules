resource "random_id" "default" {
  byte_length = 4
  keepers {
    name = "${var.app_id}-${var.service_id}-${var.datacenter}-${var.environment != "production" ? format("%.3s-", var.environment) : ""}db"
    service_id = "${var.service_id}"
    datacenter = "${var.datacenter}"
    environment = "${var.environment}"
  }
}

resource "google_compute_instance" "default" {
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      type = "${var.disk_type}"
    }
  }
  count = "${var.count}"
  labels {
    service = "${random_id.default.keepers.service_id}"
    environment = "${random_id.default.keepers.environment}"
    datacenter = "${random_id.default.keepers.datacenter}"
    index = "${count.index}"
  }
  machine_type = "${var.machine_type}"
  name = "gce-${random_id.default.keepers.name}-${random_id.default.hex}${count.index}"
  network_interface {
    network = "${var.network}"
    access_config {
      # Ephemeral IP
    }
  }
  service_account {
    scopes = ["${var.service_scopes}"]
  }
  tags = ["${concat(var.tags, list(
    "gce-${random_id.default.keepers.name}-${random_id.default.hex}${count.index}",
    "db",
    "${random_id.default.keepers.service_id}",
    "${random_id.default.keepers.environment}",
    "${random_id.default.keepers.datacenter}"
  ))}"]
  zone = "${var.region_zone}"

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

resource "google_compute_firewall" "external" {
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
  name = "${google_compute_instance.default.name}-external"
  network = "${var.network}"
  priority = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = [
    "${google_compute_instance.default.*.name}",
  ]
}

resource "google_compute_firewall" "internal" {
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
  name = "${google_compute_instance.default.name}-internal"
  network = "${var.network}"
  priority = 1000
  source_ranges = [
    "10.128.0.0/9",
  ]
  target_tags = [
    "${google_compute_instance.default.name}",
  ]
}
