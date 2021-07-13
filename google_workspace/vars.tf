variable site_setup {
  default = false
  description = "Specifies if A and AAAA records should be set up when hosting with Google Sites, disable this if using other hosting options."
  type = bool
}

variable email_setup {
  default = true
  description = "Specifies if Google Workspace email DNS MX records should set up."
  type = bool
}

variable spf_setup {
  default = true
  description = "Specifies if SPF (Sender Policy Framework) should be set up (see https://support.google.com/a/answer/33786)"
  type = bool
}

variable custom_urls_setup {
  default = false
  description = "Specifies if custom URLs should be set up for Google Workspace email (mail.example.com), Google Workspace calendar (calendar.example.com), and Google Drive (drive.example.com)."
  type = bool
}

variable domain_verification_code {
  default = ""
  description = "Specifies the domain verification code to be stored as a TXT record (the code only, without 'google-site-verification=', see https://support.google.com/a/answer/183895#generic_TXT&zippy=%2Cstep-get-your-verification-code-from-google-workspace)"
  type = string
}

variable dns_managed_zone {
  description = "The DNS managed zone resource."
  type = object({
    name = string
    dns_name = string
  })
}
