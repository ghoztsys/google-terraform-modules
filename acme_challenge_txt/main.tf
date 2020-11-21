terraform {
  required_version = ">= 0.13.5"
}

provider "google" {
  version = "~> 3.47.0"
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
