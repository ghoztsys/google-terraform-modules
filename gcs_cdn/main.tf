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
  provider = "google"
  count = "${(var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0}"
  certificate = "${var.ssl_certificate}"
  private_key = "${var.ssl_private_key}"
  lifecycle {
    create_before_destroy = false
  }
}

# Create a managed SSL certificate (optional).
resource "google_compute_managed_ssl_certificate" "default" {
  provider = "google-beta"
  count = "${length(var.ssl_domains)}"
  name = "${var.name}-managed-cert-${count.index}"
  managed {
    domains = [
      "${element(var.ssl_domains, count.index)}",
    ]
  }
  lifecycle {
    create_before_destroy = false
  }
}

# Create an HTTP target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_http_proxy" "default" {
  name = "${var.name}-http-proxy"
  url_map = "${google_compute_url_map.default.self_link}"
}

# Create an HTTPS target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_https_proxy" "default" {
  count = "${(length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0}"
  name = "${var.name}-https-proxy"
  url_map = "${google_compute_url_map.default.self_link}"
  ssl_certificates = ["${compact(concat(google_compute_ssl_certificate.default.*.self_link, google_compute_managed_ssl_certificate.default.*.self_link))}"]
}

# Create a global forwarding rule for HTTP routing. Refer to the load balancing
# target proxy and the reserved global address.
resource "google_compute_global_forwarding_rule" "http" {
  name = "${var.name}"
  target = "${google_compute_target_http_proxy.default.self_link}"
  ip_address = "${google_compute_global_address.default.address}"
  port_range = "80"
  depends_on = [
    "google_compute_global_address.default",
  ]
}

# Create a global forwarding rule for HTTPS routing (if SSL is enabled). Refer
# to the load balancing target proxy and the reserved global address.
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

# Create a URL map for the load balancer.
resource "google_compute_url_map" "default" {
  name = "${var.name}-url-map"
  default_service = "${google_compute_backend_bucket.default.self_link}"
  host_rule {
    hosts = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_bucket.default.self_link}"
  }
}

# Create the GCS bucket.
resource "google_storage_bucket" "default" {
  name = "${var.name}-bucket"
  location = "${var.bucket_location}"
  force_destroy = true
  lifecycle {
    create_before_destroy = false
  }
}

# Create the backend bucket.
resource "google_compute_backend_bucket" "default" {
  name = "${var.name}-backend-bucket"
  bucket_name = "${google_storage_bucket.default.name}"
  enable_cdn = true
  depends_on = [
    "google_storage_bucket.default",
  ]
  lifecycle {
    create_before_destroy = false
  }
}
