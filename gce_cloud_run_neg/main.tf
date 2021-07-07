terraform {
  required_version = ">= 1.0.1"

  required_providers {
    google = ">= 3.74.0"
    google-beta = ">= 3.74.0"
    random = ">= 3.1.0"
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

data "google_iam_policy" "no_auth" {
  count = var.no_auth ? 1 : 0

  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth" {
  count = var.no_auth ? 1 : 0

  location = var.region
  service = var.service_name
  policy_data = data.google_iam_policy.no_auth[0].policy_data
}
