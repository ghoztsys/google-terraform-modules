locals {
  # See https://support.google.com/a/answer/2716802?hl=en&ref_topic=2716886
  txt_records = compact([
    var.spf_setup ? "\"v=spf1 include:_spf.google.com ~all\"" : "",
    var.domain_verification_code != "" ? "google-site-verification=${var.domain_verification_code}" : "",
  ])
}

# Set up A/AAAA records to enable naked domain for Google Sites.
module "site" {
  source = "../cloud_dns_naked_domain_record_set"
  count  = var.site_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name         = var.dns_managed_zone.dns_name
  project      = var.project
}

# Set up Google Workspace email via MX records.
module "email" {
  source = "../cloud_dns_mx_record_set"
  count  = var.email_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name         = var.dns_managed_zone.dns_name
  project      = var.project
}

# Create custom URLs for Google Workspace apps.
module "custom_urls" {
  source   = "../cloud_dns_subdomain_record_set"
  for_each = toset(var.custom_urls)

  managed_zone = var.dns_managed_zone.name
  name         = "${each.value}.${var.dns_managed_zone.dns_name}"
  project      = var.project
}

# Set up TXT record for Google Workspace SPF and/or Google site verification.
resource "google_dns_record_set" "txt" {
  count = length(local.txt_records) > 0 ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name         = var.dns_managed_zone.dns_name
  project      = var.project
  rrdatas      = local.txt_records
  ttl          = 3600
  type         = "TXT"
}

# Set up TXT record for DMARC
resource "google_dns_record_set" "dmarc" {
  count = var.dmarc_setup ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name         = "_dmarc.${var.dns_managed_zone.dns_name}"
  rrdatas      = ["\"v=DMARC1;\" \"p=reject;\" \"rua=mailto:dmarc-reports@${var.dns_managed_zone.dns_name}\""]
  ttl          = 3600
  type         = "TXT"
}

# Set up TXT record for DKIM
resource "google_dns_record_set" "dkim" {
  count = var.dkim_setup != "" ? 1 : 0

  managed_zone = var.dns_managed_zone.name
  name         = "google._domainkey.${var.dns_managed_zone.dns_name}"
  rrdatas      = [var.dkim_setup]
  ttl          = 3600
  type         = "TXT"
}
