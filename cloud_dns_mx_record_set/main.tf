resource "google_dns_record_set" "mx" {
  managed_zone = var.managed_zone
  name         = var.name
  project      = var.project_id
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ]
  ttl  = var.ttl
  type = "MX"
}
