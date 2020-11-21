# Infrastructure: Cloud Run (fully managed) backend, Cloud Storage CDN, HTTP(S) load balancer, maanged SSL.

terraform {
  required_version = ">= 0.13.5"

  required_providers {
    google = ">= 3.48.0"
    google-beta = ">= 3.48.0"
    random = ">= 3.0.0"
  }
}

# Create regional serverless network endpoint group for Cloud Run service backend.
resource "google_compute_region_network_endpoint_group" "default" {
  name = "${var.name}-neg"
  network_endpoint_type = "SERVERLESS"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.default.name
    tag = var.tag
  }
}

# Create the Cloud Run service.
resource "google_cloud_run_service" "default" {
  name = var.name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/sybl-w3/www:latest"
        env {
          name = "DEBUG"
          value = "app*"
        }
        env {
          name = "CORE_ENDPOINT"
          value = "https://core.sybl.io"
        }
      }
    }
  }

  traffic {
    percent = 100
    latest_revision = true
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

  location = google_cloud_run_service.default.location
  project = google_cloud_run_service.default.project
  service = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.no_auth[0].policy_data
}
