locals {
  # Generate a list of generated health check resource links.
  health_check_links = [for health_check in google_compute_health_check.default : health_check.self_link]

  # Generate a list of all ports to allow access by GFEs per Backend Service.
  firewall_ports = distinct(concat(
    [for health_check in var.health_checks :
      lookup(health_check, "port", var.protocol == "HTTPS" ? 443 : 80)
    ],
    compact([for backend in var.backends :
      lookup(backend, "port", 8080)
    ]),
  ))
}

# Create Health Check resource(s).
resource "google_compute_health_check" "default" {
  for_each = zipmap(range(length(var.health_checks)), var.health_checks)

  name    = "${var.name}-health-check${each.key}"
  project = var.project_id

  dynamic "http_health_check" {
    for_each = var.protocol == "HTTP" ? [each.value] : []

    content {
      port         = lookup(http_health_check.value, "port", 80)
      request_path = lookup(http_health_check.value, "path", "/health")
    }
  }

  dynamic "https_health_check" {
    for_each = var.protocol == "HTTPS" ? [each.value] : []

    content {
      port         = lookup(https_health_check.value, "port", 443)
      request_path = lookup(https_health_check.value, "path", "/health")
    }
  }
}

# Create Backend Service if applicable.
resource "google_compute_backend_service" "default" {
  count = var.type == "service" ? 1 : 0

  enable_cdn            = var.regional ? false : var.enable_cdn
  health_checks         = length(local.health_check_links) == 0 ? null : local.health_check_links
  load_balancing_scheme = "EXTERNAL"
  name                  = var.name
  project               = var.project_id
  port_name             = var.port_name
  protocol              = var.protocol
  security_policy       = var.security_policy
  timeout_sec           = var.timeout

  log_config {
    enable = var.enable_logging
    sample_rate = var.enable_logging ? 1 : null
  }

  dynamic "backend" {
    for_each = toset(var.backends)

    content {
      balancing_mode               = lookup(backend.value, "balancing_mode", null)
      capacity_scaler              = lookup(backend.value, "capacity_scaler", null)
      description                  = lookup(backend.value, "description", null)
      group                        = lookup(backend.value, "group", null)
      max_connections              = lookup(backend.value, "max_connections", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_rate                     = lookup(backend.value, "max_rate", null)
      max_rate_per_instance        = lookup(backend.value, "max_rate_per_instance", null)
      max_utilization              = lookup(backend.value, "max_utilization", null)
    }
  }
}

# Create Backend Bucket if applicable.
resource "google_compute_backend_bucket" "default" {
  count = var.type == "bucket" ? 1 : 0

  bucket_name = google_storage_bucket.default[0].name
  enable_cdn  = var.regional ? false : var.enable_cdn
  name        = var.name
  project     = var.project_id
}

# Create a GCS bucket if this is a Backend Bucket.
resource "google_storage_bucket" "default" {
  count = var.type == "bucket" ? 1 : 0

  force_destroy               = true
  labels                      = var.labels
  location                    = var.location
  name                        = "${var.name}-bucket"
  project                     = var.project_id
  storage_class               = var.regional ? "REGIONAL" : null
  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "lifecycle_rule" {
    for_each = var.regional ? [true] : []

    content {
      action {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }

      condition {
        matches_storage_class = ["REGIONAL"]
      }
    }
  }

  versioning {
    enabled = var.versioning
  }

  cors {
    origin          = lookup(var.cors, "origin", null)
    method          = lookup(var.cors, "method", null)
    response_header = lookup(var.cors, "response_header", null)
    max_age_seconds = lookup(var.cors, "max_age_seconds", null)
  }
}

# Configure ACL for the provisioned GCS bucket if this service is a Backend
# Bucket.
resource "google_storage_bucket_acl" "default" {
  count = var.type == "bucket" ? 1 : 0

  bucket      = google_storage_bucket.default[0].name
  default_acl = var.default_acl
}

# Create a firewall rule so the load balancer can perform health checks and send
# load-balanced packets to this service (see
# https://cloud.google.com/load-balancing/docs/https#firewall_rules). At the
# minimum, the firewall must allow the ports exposed by each backend and used by
# each health check resource.
resource "google_compute_firewall" "default" {
  count = length(local.firewall_ports)

  name    = "${var.name}-firewall"
  network = var.network
  project = var.project_id
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_tags = flatten([for backend in var.backends :
    lookup(backend, "target_tags", [])
  ])

  allow {
    protocol = "tcp"
    ports    = local.firewall_ports
  }
}
