terraform {
  required_version = ">= 0.12.24"

  required_providers {
    google = ">= 3.19.0"
    google-beta = ">= 3.19.0"
  }
}

# Reserve a global static external IP for the load balancer. This will be the address that users use to reach the load
# balancer.
resource "google_compute_global_address" "default" {
  name = "${var.name}-address"
  ip_version = var.ip_version
}

# If the appropriate parameters are provided, create a self-signed SSL certificate. This certifcate does not interfere
# with any Google-managed certificates created in this module. Note that this is not recommended in production.
resource "google_compute_ssl_certificate" "default" {
  certificate = var.ssl_certificate
  count = (var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0
  private_key = var.ssl_private_key
  provider = google
}

# Create Google-managed SSL certificates as per specified parameter. Certificates created by this resource do not
# interfere with the self-signed certificate.
resource "google_compute_managed_ssl_certificate" "default" {
  count = length(var.ssl_domains)
  name = "${var.name}-default-cert-${count.index}"
  provider = google-beta

  managed {
    domains = [
      element(var.ssl_domains, count.index),
    ]
  }
}

# Create a Target HTTP Proxy resource to route incoming HTTP requests to a URL map. The URL map is automatically derived
# from within this module.
resource "google_compute_target_http_proxy" "default" {
  count = var.enable_http ? 1 : 0
  name = "${var.name}-http-proxy"
  url_map = element(compact(concat(list(var.url_map), google_compute_url_map.default[*].self_link)), 0)
}

# Create a Target HTTPS Proxy resource to route incoming HTTPS requests to a URL map. The URL map is automatically
# derived from within this module.
resource "google_compute_target_https_proxy" "default" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0
  name = "${var.name}-https-proxy"
  ssl_certificates = compact(concat(google_compute_ssl_certificate.default[*].self_link, google_compute_managed_ssl_certificate.default[*].self_link))
  url_map = element(compact(concat(list(var.url_map), google_compute_url_map.default[*].self_link)), 0)
}

# Create a global forwarding rule for HTTP routing using the created Target HTTP Proxy resource and reserved external
# IP.
resource "google_compute_global_forwarding_rule" "http" {
  count = var.enable_http ? 1 : 0
  depends_on = [
    google_compute_global_address.default,
  ]
  ip_address = google_compute_global_address.default.address
  name = var.name
  port_range = "80"
  target = google_compute_target_http_proxy.default[0].self_link
}

# Create a global forwarding rule for HTTPS routing (if SSL is enabled) using the created Target HTTPS Proxy resource
# and reserved external IP.
resource "google_compute_global_forwarding_rule" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0
  depends_on = [
    google_compute_global_address.default,
  ]
  ip_address = google_compute_global_address.default.address
  name = "${var.name}-https"
  port_range = "443"
  target = google_compute_target_https_proxy.default[0].self_link
}

# Create a basic URL map for the load balancer for convenience if specified to do so. This URL map simply routes all
# paths to the first backend service.
resource "google_compute_url_map" "default" {
  count = var.create_url_map ? 1 : 0
  default_service = google_compute_backend_service.default[0].self_link
  name = "${var.name}-url-map"

  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.default[0].self_link
  }
}

# Create backend service(s) from provided parameters.
resource "google_compute_backend_service" "default" {
  count = length(var.backend_services_params)
  enable_cdn = var.enable_cdn
  health_checks = [
    element(google_compute_http_health_check.default[*].self_link, count.index),
  ]
  name = "${var.name}-backend-${count.index}"
  port_name = lookup(var.backend_services_params[count.index], "port_name", "http")
  protocol = var.backend_protocol
  security_policy = var.security_policy
  timeout_sec = lookup(var.backend_services_params[count.index], "timeout", 10)

  dynamic "backend" {
    for_each = [var.backend_services[count.index]]

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

# Create health check resource(s) for the backend service(s).
resource "google_compute_http_health_check" "default" {
  count = length(var.backend_services_params)
  name = "${var.name}-backend-${count.index}"
  port = lookup(var.backend_services_params[count.index], "port", 80)
  request_path = lookup(var.backend_services_params[count.index], "health_check_path", "/health")
}

# Create firewall rule(s) to grant external access to all backend service(s).
resource "google_compute_firewall" "default" {
  count = length(var.backend_services_params)
  name = "${var.name}-firewall-${count.index}"
  network = "default"
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]
  target_tags = var.target_tags

  allow {
    protocol = "tcp"
    ports = [
      lookup(var.backend_services_params[count.index], "port", 80),
    ]
  }
}
