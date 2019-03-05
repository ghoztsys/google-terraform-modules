# Set up A records to enable naked domain (IPv4).
# @see https://support.google.com/a/answer/2579934?visit_id=1-636447692970509696-3484342373&rd=1
resource "google_dns_record_set" "a" {
  name = "${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "A"
  ttl = 3600
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ],
  lifecycle {
    create_before_destroy = false
  }
}

# Set up AAAA records to enable naked domain (IPv6).
# @see https://support.google.com/a/answer/2579934?visit_id=1-636447692970509696-3484342373&rd=1
resource "google_dns_record_set" "aaaa" {
  name = "${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "AAAA"
  ttl = 3600
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ],
  lifecycle {
    create_before_destroy = false
  }
}

# Set up MX records.
resource "google_dns_record_set" "mx" {
  name = "${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "MX"
  ttl = 3600
  rrdatas = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com.",
  ],
  lifecycle {
    create_before_destroy = false
  }
}

# Create custom URL for G Suite email.
resource "google_dns_record_set" "mail" {
  name = "mail.${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "CNAME"
  ttl = 300
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  lifecycle {
    create_before_destroy = false
  }
}

# Create custom URL for G Suite calendar.
resource "google_dns_record_set" "calendar" {
  name = "calendar.${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "CNAME"
  ttl = 300
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  lifecycle {
    create_before_destroy = false
  }
}

# Create custom URL for G Suite Drive.
resource "google_dns_record_set" "drive" {
  name = "drive.${var.dns_name}"
  managed_zone = "${var.dns_managed_zone}"
  type = "CNAME"
  ttl = 300
  rrdatas = [
    "ghs.googlehosted.com.",
  ],
  lifecycle {
    create_before_destroy = false
  }
}
