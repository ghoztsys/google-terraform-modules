data "google_iam_policy" "default" {
  count = length(var.invokers) > 0 ? 1 : 0

  binding {
    members = var.invokers
    role    = "roles/run.invoker"
  }
}

resource "google_cloud_run_service" "default" {
  autogenerate_revision_name = true
  name                       = var.name
  location                   = var.location
  project                    = var.project

  metadata {
    labels = var.labels
  }

  template {
    spec {
      service_account_name = var.service_account

      containers {
        image = var.container.image

        dynamic "env" {
          for_each = var.container.env

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.container.secrets

          content {
            name = env.key

            value_from {
              secret_key_ref {
                key  = env.value.key
                name = env.value.name
              }
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_domain_mapping" "default" {
  count = var.domain_mapping == null ? 0 : 1

  location = google_cloud_run_service.default.location
  name     = var.domain_mapping

  metadata {
    labels    = google_cloud_run_service.default.metadata[0].labels
    namespace = google_cloud_run_service.default.metadata[0].namespace
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}

resource "google_compute_region_network_endpoint_group" "default" {
  count = var.neg == null ? 0 : 1

  name                  = "${google_cloud_run_service.default.name}-neg"
  network_endpoint_type = "SERVERLESS"
  project               = var.project
  region                = google_cloud_run_service.default.location

  cloud_run {
    service = google_cloud_run_service.default.name
    tag     = var.neg.tag
  }
}

resource "google_cloud_run_service_iam_policy" "default" {
  count = length(var.invokers) > 0 ? 1 : 0

  location    = google_cloud_run_service.default.location
  policy_data = data.google_iam_policy.default[0].policy_data
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
}
