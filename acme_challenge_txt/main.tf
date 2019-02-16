resource "google_dns_record_set" "default" {
  name = "_acme-challenge.${var.subdomain == "" ? "" : format("%s.", var.subdomain)}${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "TXT"
  ttl = 3600
  rrdatas = ["${var.value}"]
  lifecycle {
    create_before_destroy = false
  }
}
