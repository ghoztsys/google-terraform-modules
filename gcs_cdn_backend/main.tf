terraform {
  required_version = ">= 0.12.24"

  required_providers {
    google = ">= 2.20.3"
  }
}

resource "google_storage_bucket" "default" {
  force_destroy = true
  location = var.bucket_location
  name = "${var.name}-bucket"
}

resource "google_storage_bucket_acl" "default" {
  bucket = google_storage_bucket.default.name
  default_acl = "publicread"
}

resource "google_compute_backend_bucket" "default" {
  bucket_name = google_storage_bucket.default.name
  depends_on = [
    google_storage_bucket.default,
  ]
  enable_cdn = true
  name = "${var.name}-backend-bucket"
}
