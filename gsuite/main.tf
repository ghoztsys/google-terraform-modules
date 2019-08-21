# Set up A records to enable naked domain (IPv4).
# @see https://support.google.com/a/answer/2579934?visit_id=1-636447692970509696-3484342373&rd=1
resource "google_dns_record_set" "a" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "${var.dns_name}"
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ],
  ttl = 3600
  type = "A"
}

# Set up AAAA records to enable naked domain (IPv6).
# @see https://support.google.com/a/answer/2579934?visit_id=1-636447692970509696-3484342373&rd=1
resource "google_dns_record_set" "aaaa" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "${var.dns_name}"
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ],
  ttl = 3600
  type = "AAAA"
}

# Set up MX records.
resource "google_dns_record_set" "mx" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "${var.dns_name}"
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ],
  ttl = 3600
  type = "MX"
}

# Create custom URL for G Suite email.
resource "google_dns_record_set" "mail" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "mail.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  ttl = 300
  type = "CNAME"
}

# Create custom URL for G Suite calendar.
resource "google_dns_record_set" "calendar" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "calendar.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  ttl = 300
  type = "CNAME"
}

# Create custom URL for G Suite Drive.
resource "google_dns_record_set" "drive" {
  lifecycle {
    create_before_destroy = false
  }
  managed_zone = "${var.dns_managed_zone}"
  name = "drive.${var.dns_name}"
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  ttl = 300
  type = "CNAME"
}
