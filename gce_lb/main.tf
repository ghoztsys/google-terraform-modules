# This module creates an HTTP(S) load balancer on GCP using forwarding rules.

provider "google" {
  project = "${var.project_id}"
  region = "${var.region}"
}

provider "google-beta" {
  project = "${var.project_id}"
  region = "${var.region}"
}

resource "google_compute_global_address" "default" {
  name = "${var.name}-address"
  ip_version = "${var.ip_version}"
}

resource "google_compute_global_forwarding_rule" "http" {
  name = "${var.name}"
  target = "${google_compute_target_http_proxy.default.self_link}"
  ip_address = "${google_compute_global_address.default.address}"
  port_range = "80"
  depends_on = [
    "google_compute_global_address.default",
  ]
}

resource "google_compute_global_forwarding_rule" "https" {
  count = "${(length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0}"
  name = "${var.name}-https"
  target = "${google_compute_target_https_proxy.default.self_link}"
  ip_address = "${google_compute_global_address.default.address}"
  port_range = "443"
  depends_on = [
    "google_compute_global_address.default",
  ]
}

resource "google_compute_ssl_certificate" "custom" {
  provider = "google"
  count = "${(var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0}"
  certificate = "${var.ssl_certificate}"
  private_key = "${var.ssl_private_key}"
  lifecycle {
    create_before_destroy = false
  }
}

resource "google_compute_ssl_certificate" "managed" {
  provider = "google-beta"
  count = "${length(var.ssl_domains)}"
  type = "MANAGED"
  managed {
    domains = [
      "${element(var.ssl_domains, count.index)}"
    ]
  }
  lifecycle {
    create_before_destroy = false
  }
}

resource "google_compute_target_http_proxy" "default" {
  name = "${var.name}-http-proxy"
  url_map = "${element(compact(concat(google_compute_url_map.with_backend_bucket.*.self_link, google_compute_url_map.default.*.self_link)), 0)}"
}

resource "google_compute_target_https_proxy" "default" {
  count = "${(length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0}"
  name = "${var.name}-https-proxy"
  url_map = "${element(compact(concat(google_compute_url_map.with_backend_bucket.*.self_link, google_compute_url_map.default.*.self_link)), 0)}"
  ssl_certificates = ["${compact(concat(google_compute_ssl_certificate.custom.*.self_link, google_compute_ssl_certificate.managed.*.self_link))}"]
}

resource "google_compute_url_map" "default" {
  count = "${(length(var.backend_bucket_params) == 0) ? 1 : 0}"
  name = "${var.name}-url-map"
  default_service = "${google_compute_backend_service.default.0.self_link}"
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.default.0.self_link}"
  }
}

resource "google_compute_url_map" "with_backend_bucket" {
  count = "${(length(var.backend_bucket_params) == 0) ? 0 : 1}"
  name = "${var.name}-url-map"
  default_service = "${google_compute_backend_service.default.0.self_link}"
  host_rule {
    hosts = [
      "*",
    ]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.default.0.self_link}"
    path_rule {
      paths = [
        "${element(split(",", element(var.backend_bucket_params, 0)), 0)}",
      ]
      service = "${google_compute_backend_bucket.default.0.self_link}"
    }
  }
}

resource "google_compute_backend_service" "default" {
  count = "${length(var.backend_service_params)}"
  name = "${var.name}-backend-${count.index}"
  protocol = "${var.backend_protocol}"
  port_name = "${element(split(",", element(var.backend_service_params, count.index)), 1)}"
  timeout_sec = "${element(split(",", element(var.backend_service_params, count.index)), 3)}"
  backend = [
    "${var.backend_services["${count.index}"]}",
  ]
  health_checks = [
    "${element(google_compute_http_health_check.default.*.self_link, count.index)}",
  ]
  security_policy = "${var.security_policy}"
  enable_cdn = "${var.enable_cdn}"
}

resource "google_compute_backend_bucket" "default" {
  count = "${length(var.backend_bucket_params)}"
  name = "${var.name}-backend-bucket-${count.index}"
  bucket_name = "${element(google_storage_bucket.default.*.name, count.index)}"
  enable_cdn = "${var.enable_cdn}"
  depends_on = [
    "google_storage_bucket.default",
  ]
}

resource "google_storage_bucket" "default" {
  count = "${length(var.backend_bucket_params)}"
  name = "${var.name}-bucket-${count.index}"
  location = "${element(split(",", element(var.backend_bucket_params, count.index)), 2)}"
  force_destroy = true
}

resource "google_compute_http_health_check" "default" {
  count = "${length(var.backend_service_params)}"
  name = "${var.name}-backend-${count.index}"
  request_path = "${element(split(",", element(var.backend_service_params, count.index)), 0)}"
  port = "${element(split(",", element(var.backend_service_params, count.index)), 2)}"
}

resource "google_compute_firewall" "default" {
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
  allow {
    protocol = "tcp"
    ports = [
      "${element(split(",", element(var.backend_service_params, count.index)), 2)}",
    ]
  }
}
