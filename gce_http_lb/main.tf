terraform {
  required_version = ">= 1.0.1"

  required_providers {
    google = ">= 3.74.0"
    google-beta = ">= 3.74.0"
  }
}

# Generate a random name for the managed SSL certificate based on the list of SSL domains. This is necessary when
# updating the `google_compute_managed_ssl_certificate` resource because if the the new resource has the same name as
# the previous resource, the API will have conflict updating the HTTPS proxy.
resource "random_id" "managed_cert" {
  count = length(var.ssl_domains) > 0 ? 1 : 0
  byte_length = 4

  keepers = {
    domains = join(",", var.ssl_domains)
  }
}

# Reserve a global static external IP for the load balancer. This will be the address that users use to reach the load
# balancer.
resource "google_compute_global_address" "default" {
  address_type = "EXTERNAL"
  ip_version = var.ip_version
  name = "${var.name}-address"
}

# Create a Target HTTP Proxy resource to route incoming HTTP requests to a URL map. The URL map is either provided or is
# automatically derived with default configuration. This resource is only created if `enable_http` is `true`.
resource "google_compute_target_http_proxy" "http" {
  count = var.enable_http ? 1 : 0

  name = "${var.name}-http-proxy"
  url_map = local.redirect_http ? google_compute_url_map.redirect[0].self_link : (var.url_map == null ? google_compute_url_map.default[0].self_link : var.url_map)
}

# Create a global forwarding rule for HTTP routing using the Target HTTP Proxy resource and reserved external IP. This
# resource is only created if `enable_http` is `true`.
resource "google_compute_global_forwarding_rule" "http" {
  count = var.enable_http ? 1 : 0

  ip_address = google_compute_global_address.default.address
  ip_version = var.ip_version
  load_balancing_scheme = "EXTERNAL"
  name = var.name
  port_range = 80
  target = google_compute_target_http_proxy.http[0].self_link
}

# Create a self-signed SSL certificate resource if the certificate and key are provided. This does not interfere with
# any Google-managed certificates created in this module. Note that this is not recommended to be used in production.
resource "google_compute_ssl_certificate" "https" {
  count = (var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0

  certificate = var.ssl_certificate
  private_key = var.ssl_private_key
  provider = google
}

# Create a Google-managed SSL certificate for all domains defined in `ssl_domains`. This certificate does not interfere
# with the self-signed certificate (if applicable).
resource "google_compute_managed_ssl_certificate" "https" {
  count = length(var.ssl_domains) > 0 ? 1 : 0

  name = "${var.name}-cert-${random_id.managed_cert[0].hex}"
  provider = google-beta

  managed {
    domains = var.ssl_domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a Target HTTPS Proxy resource to route incoming HTTPS requests to a URL map. The URL map is either provided or
# is automatically derived with default configuration. This resource is only created if SSL certificates are properly
# set up.
resource "google_compute_target_https_proxy" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  name = "${var.name}-https-proxy"
  ssl_certificates = compact(concat(google_compute_ssl_certificate.https[*].self_link, google_compute_managed_ssl_certificate.https[*].self_link))
  url_map = element(compact(concat([var.url_map], google_compute_url_map.default[*].self_link)), 0)
}

# Create a global forwarding rule for HTTPS routing (if SSL certificates are properly set up) using the Target HTTPS
# Proxy resource and reserved external IP.
resource "google_compute_global_forwarding_rule" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  ip_address = google_compute_global_address.default.address
  ip_version = var.ip_version
  load_balancing_scheme = "EXTERNAL"
  name = "${var.name}-https"
  port_range = 443
  target = google_compute_target_https_proxy.https[0].self_link
}

# Create Health Check resource(s) for every Backend Service resource.
resource "google_compute_health_check" "default" {
  for_each = { for health_check in local.health_checks: "backend${health_check.backend_service_index}-health-check${health_check.index}" => health_check }

  name = "${var.name}-${each.key}"

  dynamic "http_health_check" {
    for_each = lookup(var.backend_services[each.value.backend_service_index], "protocol", "HTTP") == "HTTPS" ? [] : [each.value]

    content {
      port = http_health_check.value.port
      request_path = http_health_check.value.path
    }
  }

  dynamic "https_health_check" {
    for_each = lookup(var.backend_services[each.value.backend_service_index], "protocol", "HTTP") == "HTTPS" ? [each.value] : []

    content {
      port = https_health_check.value.port
      request_path = https_health_check.value.path
    }
  }
}

# Create Backend Service(s) from provided descriptor.
resource "google_compute_backend_service" "default" {
  for_each = local.backend_services

  enable_cdn = lookup(each.value, "enable_cdn", false)
  health_checks = length(local.health_check_links[each.key]) == 0 ? null : local.health_check_links[each.key]
  load_balancing_scheme = "EXTERNAL"
  name = "${var.name}-backend${each.key}"
  port_name = lookup(each.value, "port_name", null)
  protocol = lookup(each.value, "protocol", "HTTP")
  security_policy = lookup(each.value, "security_policy", null)
  timeout_sec = lookup(each.value, "timeout", null)

  dynamic "backend" {
    for_each = toset(var.backends[each.key])

    content {
      balancing_mode = lookup(backend.value, "balancing_mode", null)
      capacity_scaler = lookup(backend.value, "capacity_scaler", null)
      description = lookup(backend.value, "description", null)
      group = lookup(backend.value, "group", null)
      max_connections = lookup(backend.value, "max_connections", null)
      max_connections_per_instance = lookup(backend.value, "max_connections_per_instance", null)
      max_rate = lookup(backend.value, "max_rate", null)
      max_rate_per_instance = lookup(backend.value, "max_rate_per_instance", null)
      max_utilization = lookup(backend.value, "max_utilization", null)
    }
  }
}

# Create Backend Bucket(s) from provided descriptor.
resource "google_compute_backend_bucket" "default" {
  for_each = local.backend_buckets

  bucket_name = google_storage_bucket.default[each.key].name
  enable_cdn = lookup(each.value, "enable_cdn", false)
  name = "${var.name}-backend-bucket${each.key}"
}

# Create GCS buckets for each backend bucket.
resource "google_storage_bucket" "default" {
  for_each = local.backend_buckets

  force_destroy = true
  location = lookup(each.value, "location", "US")
  name = "${var.name}-bucket${each.key}"
  labels = lookup(each.value, "labels", {})

  versioning {
    enabled = lookup(each.value, "versioning", false)
  }

  cors {
    origin = lookup(lookup(each.value, "cors", {}), "origin", null)
    method = lookup(lookup(each.value, "cors", {}), "method", null)
    response_header = lookup(lookup(each.value, "cors", {}), "response_header", null)
    max_age_seconds = lookup(lookup(each.value, "cors", {}), "max_age_seconds", null)
  }
}

# Configure ACL for each GCS bucket.
resource "google_storage_bucket_acl" "default" {
  for_each = local.backend_buckets

  bucket = google_storage_bucket.default[each.key].name
  default_acl = lookup(each.value, "default_acl", "publicread")
}

# Create a HTTP URL map for HTTP-to-HTTPS redirection only, if needed.
resource "google_compute_url_map" "redirect" {
  count = local.redirect_http ? 1 : 0

  name = "${var.name}-url-map-redirect"

  default_url_redirect {
    https_redirect = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query = false
  }
}

# Create a basic URL map for the load balancer if `create_url_map` is `true`. This URL map routes all paths to the first
# Backend Service resource created.
resource "google_compute_url_map" "default" {
  count = var.url_map == null ? 1 : 0
  default_service = google_compute_backend_service.default[0].self_link
  name = "${var.name}-url-map"

  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.default[0].self_link

    dynamic "path_rule" {
      for_each = toset(local.path_rules)

      content {
        service = path_rule.value.service
        paths = path_rule.value.paths
      }
    }
  }
}

# Create a firewall rule per Backend Service so the load balancer can perform health checks and send load-balanced
# packets to the backends (see https://cloud.google.com/load-balancing/docs/https#firewall_rules). At the minimum, the
# firewall must allow the ports used by each forwarding rule and health check resource.
resource "google_compute_firewall" "default" {
  count = length(local.firewall_ports)

  name = "${var.name}-firewall${count.index}"
  network = "default"
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_tags = flatten([ for backend in var.backends[count.index]: lookup(backend, "target_tags", []) ])

  allow {
    protocol = "tcp"
    ports = local.firewall_ports[count.index]
  }
}
