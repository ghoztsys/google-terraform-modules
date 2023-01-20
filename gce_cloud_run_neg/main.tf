locals {
  # Indicates if HTTP-to-HTTPS redirection should be set up.
  https_redirect = var.enable_http && var.https_redirect && (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != ""))
}

data "google_iam_policy" "no_auth" {
  count = var.no_auth ? 1 : 0

  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_compute_region_network_endpoint_group" "default" {
  name = var.name == null ? "${var.service_name}-neg" : var.name
  network_endpoint_type = "SERVERLESS"
  region = var.region

  cloud_run {
    service = var.service_name
    tag = var.tag
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth" {
  count = var.no_auth ? 1 : 0

  location = var.region
  service = var.service_name
  policy_data = data.google_iam_policy.no_auth[0].policy_data
}
