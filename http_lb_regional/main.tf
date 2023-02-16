locals {
  # Indicates if HTTP-to-HTTPS redirection should be set up.
  https_redirect = var.enable_http && var.https_redirect && (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != ""))
}

# Generate a random name for the managed SSL certificate based on the list of
# SSL domains. This is necessary when updating the
# `google_compute_managed_ssl_certificate` resource because if the the new
# resource has the same name as the previous resource, the API will have
# conflict updating the HTTPS proxy.
resource "random_id" "managed_cert" {
  count       = length(var.ssl_domains) > 0 ? 1 : 0
  byte_length = 4

  keepers = {
    domains = join(",", var.ssl_domains)
  }
}

# Reserve a regional static external IP for the load balancer. This will be the
# address that users use to reach the load balancer.
resource "google_compute_address" "default" {
  address_type = "EXTERNAL"
  name         = "${var.name}-address"
  network_tier = "STANDARD"
  region       = var.region
  project      = var.project_id
}

# Create a Target HTTP Proxy resource to route incoming HTTP requests to a URL
# map. The URL map is either provided or is automatically derived with default
# configuration. This resource is only created if `enable_http` is `true`.
resource "google_compute_target_http_proxy" "http" {
  count = var.enable_http ? 1 : 0

  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = local.https_redirect ? google_compute_url_map.redirect[0].self_link : google_compute_url_map.default.self_link
}

# Create a forwarding rule for HTTP routing using the Target HTTP Proxy resource
# and reserved external IP. This resource is only created if `enable_http` is
# `true`.
resource "google_compute_forwarding_rule" "http" {
  count = var.enable_http ? 1 : 0

  ip_address            = google_compute_address.default.address
  load_balancing_scheme = "EXTERNAL"
  name                  = var.name
  network_tier          = "STANDARD"
  port_range            = 80
  region                = var.region
  project               = var.project_id
  target                = google_compute_target_http_proxy.http[0].self_link
}

# Create a self-signed SSL certificate resource if the certificate and key are
# provided. This does not interfere any Google-managed certificates created in
# this module. Note that this is not recommended to be used in production.
resource "google_compute_region_ssl_certificate" "https" {
  count = (var.ssl_private_key != "" && var.ssl_certificate != "") ? 1 : 0

  certificate = var.ssl_certificate
  private_key = var.ssl_private_key
  region      = var.region
  project     = var.project_id

  lifecycle {
    create_before_destroy = true
  }
}

# Create Google-managed SSL certificates for every domain as defined in
# `ssl_domains`. Certificates created by this resource do not interfere with the
# self-signed certificate, if applicable.
resource "google_compute_managed_ssl_certificate" "https" {
  count = length(var.ssl_domains)

  name    = "${var.name}-${random_id.managed_cert[0].hex}-cert${count.index}"
  project = var.project_id

  managed {
    domains = [
      element(var.ssl_domains, count.index),
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a Target HTTPS Proxy resource to route incoming HTTPS requests to a URL
# map. The URL map is either provided or is automatically derived with default
# configuration. This resource is only created if SSL certificates are properly
# set up.
resource "google_compute_target_https_proxy" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  name             = "${var.name}-https-proxy"
  project          = var.project_id
  ssl_certificates = compact(concat(google_compute_region_ssl_certificate.https[*].self_link, google_compute_managed_ssl_certificate.https[*].self_link))
  url_map          = google_compute_url_map.default.self_link
}

# Create a regional forwarding rule for HTTPS routing (if SSL certificates are
# properly set up) using the Target HTTPS Proxy resource and reserved external
# IP.
resource "google_compute_forwarding_rule" "https" {
  count = (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != "")) ? 1 : 0

  ip_address            = google_compute_address.default.address
  load_balancing_scheme = "EXTERNAL"
  name                  = "${var.name}-https"
  network_tier          = "STANDARD"
  port_range            = 443
  project               = var.project_id
  region                = var.region
  target                = google_compute_target_https_proxy.https[0].self_link
}

# Create Backend Service(s)/Bucket(s).
#
# TODO: Use `null` instead of a literal value to utilize the submodule's default
# parameters. See issue https://github.com/hashicorp/terraform/issues/24142
module "backend_service" {
  for_each = zipmap(range(length(var.backend_services)), var.backend_services)
  source   = "../backend_service"

  backends                    = lookup(each.value, "backends", [])
  cors                        = lookup(each.value, "cors", {})
  default_acl                 = lookup(each.value, "default_acl", "publicread")
  health_checks               = lookup(each.value, "health_checks", [])
  labels                      = lookup(each.value, "labels", {})
  location                    = var.region
  enable_logging              = lookup(each.value, "enable_logging", null)
  enable_cdn                  = lookup(each.value, "enable_cdn", null)
  name                        = "${var.name}-backend-service${each.key}"
  network                     = var.network
  port_name                   = lookup(each.value, "port_name", null)
  project_id                  = var.project_id
  protocol                    = lookup(each.value, "protocol", "HTTP")
  regional                    = true
  security_policy             = lookup(each.value, "security_policy", null)
  timeout                     = lookup(each.value, "timeout", null)
  type                        = lookup(each.value, "type", "service")
  uniform_bucket_level_access = lookup(each.value, "uniform_bucket_level_access", false)
  versioning                  = lookup(each.value, "versioning", false)
}

# Create a HTTP URL map for HTTP-to-HTTPS redirection only, if needed.
resource "google_compute_url_map" "redirect" {
  count = local.https_redirect ? 1 : 0

  name    = "${var.name}-url-map-redirect"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    host_redirect          = var.host_redirect
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# Create a basic URL map for the load balancer. This URL map routes all paths to
# the first Backend Service resource created.
resource "google_compute_url_map" "default" {
  default_service = module.backend_service[0].self_link
  name            = "${var.name}-url-map"
  project         = var.project_id

  dynamic "host_rule" {
    for_each = zipmap(range(length(var.url_map)), var.url_map)

    content {
      hosts        = host_rule.value.hosts
      path_matcher = "path-matcher${host_rule.key}"
    }
  }

  dynamic "path_matcher" {
    for_each = zipmap(range(length(var.url_map)), var.url_map)

    content {
      name            = "path-matcher${path_matcher.key}"
      default_service = lookup(path_matcher.value, "default_url_redirect", null) == null ? lookup(module.backend_service[lookup(path_matcher.value, "default_backend_service_index", 0)], "self_link") : null

      dynamic "default_url_redirect" {
        for_each = lookup(path_matcher.value, "default_url_redirect", null) == null ? [] : [path_matcher.value.default_url_redirect]

        content {
          host_redirect          = default_url_redirect.value.host_redirect
          redirect_response_code = lookup(default_url_redirect.value, "redirect_response_code", "MOVED_PERMANENTLY_DEFAULT")
          strip_query            = lookup(default_url_redirect.value, "strip_query", false)
        }
      }

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])

        content {
          service = lookup(module.backend_service[lookup(path_rule.value, "backend_service_index", 0)], "self_link")
          paths   = path_rule.value.paths
        }
      }
    }
  }
}