locals {
  # See https://support.google.com/a/answer/2716802?hl=en&ref_topic=2716886
  txt_records = compact([
    var.spf_setup ? "\"v=spf1 include:_spf.google.com ~all\"" : "",
    var.domain_verification_code != "" ? "google-site-verification=${var.domain_verification_code}" : "",
  ])
}
