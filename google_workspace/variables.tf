variable "custom_urls" {
  default     = []
  description = "Specifies custom subdomain names to set up for Google Workspace custom URLs (i.e. 'mail' as in mail.example.com, 'calendar' as in calendar.example.com, 'drive' as in drive.example.com)."
  type        = list(string)
}

variable "dns_managed_zone" {
  description = "The DNS managed zone resource."
  type = object({
    name     = string
    dns_name = string
  })
}

variable "domain_verification_code" {
  default     = ""
  description = "Specifies the domain verification code to be stored as a TXT record (the code only, without 'google-site-verification=', see https://support.google.com/a/answer/183895#generic_TXT&zippy=%2Cstep-get-your-verification-code-from-google-workspace)"
  type        = string
}

variable "email_setup" {
  default     = true
  description = "Specifies if Google Workspace email DNS MX records should set up."
  type        = bool
}

variable "project_id" {
  description = "ID of project to create resources in."
  type        = string
}

variable "site_setup" {
  default     = false
  description = "Specifies if A and AAAA records should be set up when hosting with Google Sites, disable this if using other hosting options."
  type        = bool
}

variable "spf_setup" {
  default     = true
  description = "Specifies if SPF (Sender Policy Framework) should be set up (see https://support.google.com/a/answer/33786)"
  type        = bool
}
