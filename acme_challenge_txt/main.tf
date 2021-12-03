resource "google_dns_record_set" "default" {
  managed_zone = var.dns_managed_zone
  name = "_acme-challenge.${var.subdomain == "" ? "" : format("%s.", var.subdomain)}${var.dns_name}"
  rrdatas = [
    var.text,
  ]
  ttl = 3600
  type = "TXT"
}
