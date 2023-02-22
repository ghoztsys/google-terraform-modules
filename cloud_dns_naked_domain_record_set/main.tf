# Set up A records to enable naked domain redirect (IPv4).
resource "google_dns_record_set" "a" {
  managed_zone = var.managed_zone
  name         = var.name
  project      = var.project_id
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ]
  ttl  = var.ttl
  type = "A"
}

# Set up AAAA records to enable naked domain redirect (IPv6).
resource "google_dns_record_set" "aaaa" {
  managed_zone = var.managed_zone
  name         = var.name
  project      = var.project_id
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ]
  ttl  = var.ttl
  type = "AAAA"
}
