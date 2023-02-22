resource "google_dns_record_set" "default" {
  managed_zone = var.managed_zone
  name         = var.name
  project      = var.project_id
  rrdatas = [
    "ghs.googlehosted.com.",
  ]
  ttl  = var.ttl
  type = "CNAME"
}
