provider "google" {
  project = "${var.project_id}"
  region = "${var.region}"
}

provider "google-beta" {
  project = "${var.project_id}"
  region = "${var.region}"
}

# Reserve a static IP for the load balancer.
resource "google_compute_global_address" "default" {
  name = "${var.name}-address"
  ip_version = "${var.ip_version}"
}

# Create an SSL certificate from the provided keys (optional).
resource "google_compute_ssl_certificate" "default" {
  certificate = "${var.ssl_certificate}"
  count = "${(var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0}"
  lifecycle {
    create_before_destroy = false
  }
  private_key = "${var.ssl_private_key}"
  provider = "google"
}

# Create a default SSL certificate (optional).
resource "google_compute_managed_ssl_certificate" "default" {
  count = "${length(var.ssl_domains)}"
  lifecycle {
    create_before_destroy = false
  }
  managed {
    domains = [
      "${element(var.ssl_domains, count.index)}",
    ]
  }
  name = "${var.name}-default-cert-${count.index}"
  provider = "google-beta"
}

# Create an HTTP target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_http_proxy" "default" {
  count = "${var.enable_http ? 1 : 0}"
  name = "${var.name}-http-proxy"
  url_map = "${element(compact(concat(list(var.url_map), google_compute_url_map.default.*.self_link)), 0)}"
}

# Create an HTTPS target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_https_proxy" "default" {
  count = "${(length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0}"
  name = "${var.name}-https-proxy"
  ssl_certificates = ["${compact(concat(google_compute_ssl_certificate.default.*.self_link, google_compute_managed_ssl_certificate.default.*.self_link))}"]
  url_map = "${element(compact(concat(list(var.url_map), google_compute_url_map.default.*.self_link)), 0)}"
}

# Create a global forwarding rule for HTTP routing. Refer to the load balancing
# target proxy and the reserved global address.
resource "google_compute_global_forwarding_rule" "http" {
  count = "${var.enable_http ? 1 : 0}"
  depends_on = [
    "google_compute_global_address.default",
  ]
  ip_address = "${google_compute_global_address.default.address}"
  name = "${var.name}"
  port_range = "80"
  target = "${google_compute_target_http_proxy.default.self_link}"
}

# Create a global forwarding rule for HTTPS routing (if SSL is enabled). Refer
# to the load balancing target proxy and the reserved global address.
resource "google_compute_global_forwarding_rule" "https" {
  count = "${(length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0}"
  depends_on = [
    "google_compute_global_address.default",
  ]
  ip_address = "${google_compute_global_address.default.address}"
  name = "${var.name}-https"
  port_range = "443"
  target = "${google_compute_target_https_proxy.default.self_link}"
}

# Create a URL map for the load balancer (without a backend bucket).
resource "google_compute_url_map" "default" {
  count = "${var.create_url_map ? 1 : 0}"
  default_service = "${google_compute_backend_service.default.0.self_link}"
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  name = "${var.name}-url-map"
  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.default.0.self_link}"
  }
}

# Create backend service.
resource "google_compute_backend_service" "default" {
  backend = [
    "${var.backend_services["${count.index}"]}",
  ]
  count = "${length(var.backend_service_params)}"
  enable_cdn = "${var.enable_cdn}"
  health_checks = [
    "${element(google_compute_http_health_check.default.*.self_link, count.index)}",
  ]
  lifecycle {
    create_before_destroy = false
  }
  name = "${var.name}-backend-${count.index}"
  port_name = "${element(split(",", element(var.backend_service_params, count.index)), 1)}"
  protocol = "${var.backend_protocol}"
  security_policy = "${var.security_policy}"
  timeout_sec = "${element(split(",", element(var.backend_service_params, count.index)), 3)}"
}

resource "google_compute_http_health_check" "default" {
  count = "${length(var.backend_service_params)}"
  name = "${var.name}-backend-${count.index}"
  port = "${element(split(",", element(var.backend_service_params, count.index)), 2)}"
  request_path = "${element(split(",", element(var.backend_service_params, count.index)), 0)}"
}

resource "google_compute_firewall" "default" {
  allow {
    protocol = "tcp"
    ports = [
      "${element(split(",", element(var.backend_service_params, count.index)), 2)}",
    ]
  }
  count = "${length(var.backend_service_params)}"
  name = "${var.name}-firewall-${count.index}"
  network = "default"
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]
  target_tags = ["${var.target_tags}"]
}
