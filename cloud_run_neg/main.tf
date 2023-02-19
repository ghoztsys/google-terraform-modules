resource "google_compute_region_network_endpoint_group" "default" {
  name                  = var.name == null ? "${var.cloud_run_name}-neg" : var.name
  network_endpoint_type = "SERVERLESS"
  project               = var.project_id
  region                = var.region

  cloud_run {
    service = var.cloud_run_name
    tag     = var.tag
  }
}
