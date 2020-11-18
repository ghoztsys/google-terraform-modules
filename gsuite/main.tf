terraform {
  required_version = ">= 0.12.25"

  required_providers {
    google = ">= 3.47.0"
  }
}

# Set up A records to enable naked domain (IPv4).
resource "google_dns_record_set" "a" {
  managed_zone = var.dns_managed_zone
  name = var.dns_name
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ]
  ttl = 3600
  type = "A"
}

# Set up AAAA records to enable naked domain (IPv6).
resource "google_dns_record_set" "aaaa" {
  managed_zone = var.dns_managed_zone
  name = var.dns_name
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ]
  ttl = 3600
  type = "AAAA"
}

# Set up MX records.
resource "google_dns_record_set" "mx" {
  managed_zone = var.dns_managed_zone
  name = var.dns_name
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]
  ttl = 3600
  type = "MX"
}

# Create custom URL for G Suite email.
resource "google_dns_record_set" "mail" {
  managed_zone = var.dns_managed_zone
  name = "mail.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}

# Create custom URL for G Suite calendar.
resource "google_dns_record_set" "calendar" {
  managed_zone = var.dns_managed_zone
  name = "calendar.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}

# Create custom URL for G Suite Drive.
resource "google_dns_record_set" "drive" {
  managed_zone = var.dns_managed_zone
  name = "drive.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}
