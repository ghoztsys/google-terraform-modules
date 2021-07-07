terraform {
  required_version = ">= 1.0.1"
}

provider "google" {
  google = ">= 3.74.0"
}

resource "google_dns_record_set" "default" {
  managed_zone = var.dns_managed_zone
  name = "_acme-challenge.${var.subdomain == "" ? "" : format("%s.", var.subdomain)}${var.dns_name}"
  rrdatas = [
    var.text,
  ]
  ttl = 3600
  type = "TXT"
}
