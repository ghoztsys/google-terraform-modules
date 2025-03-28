# Reserve a static IP for the load balancer.
resource "google_compute_global_address" "default" {
  name       = "${var.name}-address"
  ip_version = var.ip_version
  project    = var.project
}

# Create an SSL certificate from the provided keys (optional).
resource "google_compute_ssl_certificate" "default" {
  count = (var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0

  certificate = var.ssl_certificate
  private_key = var.ssl_private_key
  project     = var.project
  provider    = google
}

# Create a managed SSL certificate (optional).
resource "google_compute_managed_ssl_certificate" "default" {
  count = length(var.ssl_domains)

  name     = "${var.name}-managed-cert-${count.index}"
  project  = var.project
  provider = google-beta
  managed {
    domains = [
      element(var.ssl_domains, count.index),
    ]
  }
}

# Create an HTTP target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-http-proxy"
  project = var.project
  url_map = google_compute_url_map.default.self_link
}

# Create an HTTPS target proxy for the load balancer. Automatically derive the
# URL map.
resource "google_compute_target_https_proxy" "default" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  name             = "${var.name}-https-proxy"
  project          = var.project
  ssl_certificates = compact(concat(google_compute_ssl_certificate.default[*].self_link, google_compute_managed_ssl_certificate.default[*].self_link))
  url_map          = google_compute_url_map.default.self_link
}

# Create a global forwarding rule for HTTP routing. Refer to the load balancing
# target proxy and the reserved global address.
resource "google_compute_global_forwarding_rule" "http" {
  ip_address = google_compute_global_address.default.address
  name       = var.name
  port_range = "80"
  project    = var.project
  target     = google_compute_target_http_proxy.default.self_link

  depends_on = [
    google_compute_global_address.default,
  ]
}

# Create a global forwarding rule for HTTPS routing (if SSL is enabled). Refer
# to the load balancing target proxy and the reserved global address.
resource "google_compute_global_forwarding_rule" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  ip_address = google_compute_global_address.default.address
  name       = "${var.name}-https"
  port_range = "443"
  project    = var.project
  target     = google_compute_target_https_proxy.default[0].self_link

  depends_on = [
    google_compute_global_address.default
  ]
}

# Create a URL map for the load balancer.
resource "google_compute_url_map" "default" {
  default_service = google_compute_backend_bucket.default.self_link
  name            = "${var.name}-url-map"
  project         = var.project

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.default.self_link
  }
}

# Create the GCS bucket.
resource "google_storage_bucket" "default" {
  force_destroy               = true
  location                    = var.bucket_location
  name                        = "${var.name}-bucket"
  project                     = var.project
  uniform_bucket_level_access = var.uniform_bucket_level_access
}

# Create the backend bucket.
resource "google_compute_backend_bucket" "default" {
  bucket_name = google_storage_bucket.default.name
  enable_cdn  = true
  name        = "${var.name}-backend-bucket"
  project     = var.project

  depends_on = [
    google_storage_bucket.default,
  ]
}
