terraform {
  required_version = ">= 1.0.1"

  required_providers {
    google = ">= 3.74.0"
  }
}

# Set up A records to enable naked domain for Google Sites (IPv4).
resource "google_dns_record_set" "a" {
  count = var.site_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = var.dns_managed_zone.dns_name
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ]
  ttl = 3600
  type = "A"
}

# Set up AAAA records to enable naked domain for Google Sites (IPv6).
resource "google_dns_record_set" "aaaa" {
  count = var.site_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = var.dns_managed_zone.dns_name
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ]
  ttl = 3600
  type = "AAAA"
}

# Set up Google Workspace email via MX records.
resource "google_dns_record_set" "mx" {
  count = var.email_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = var.dns_managed_zone.dns_name
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

# Set up TXT record for Google Workspace SPF and/or Google site verification.
resource "google_dns_record_set" "txt" {
  count = length(local.txt_records) > 0 ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = var.dns_managed_zone.dns_name
  rrdatas = local.txt_records
  ttl = 3600
  type = "TXT"
}

# Create custom URL for Google Workspace email.
resource "google_dns_record_set" "mail" {
  count = var.custom_urls_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = "mail.${var.dns_managed_zone.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}

# Create custom URL for Google Workspace calendar.
resource "google_dns_record_set" "calendar" {
  count = var.custom_urls_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = "calendar.${var.dns_managed_zone.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}

# Create custom URL for Google Drive.
resource "google_dns_record_set" "drive" {
  count = var.custom_urls_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name = "drive.${var.dns_managed_zone.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl = 300
  type = "CNAME"
}
