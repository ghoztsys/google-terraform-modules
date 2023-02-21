data "google_iam_policy" "default" {
  count = length(var.invokers) > 0 ? 1 : 0

  binding {
    members = var.invokers
    role = "roles/run.invoker"
  }
}

resource "google_cloud_run_service" "default" {
  autogenerate_revision_name = true
  name                       = var.name
  location                   = var.location

  metadata {
    labels = var.labels
  }

  template {
    spec {
      containers {
        image = var.container.image

        dynamic "env" {
          for_each = var.container.env

          content {
            name  = env.key
            value = env.value
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
    labels = google_cloud_run_service.default.metadata[0].labels
    namespace = google_cloud_run_service.default.metadata[0].namespace
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}

resource "google_cloud_run_service_iam_policy" "default" {
  count = length(var.invokers) > 0 ? 1 : 0

  location    = google_cloud_run_service.default.location
  policy_data = data.google_iam_policy.default[0].policy_data
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
}
