locals {
  # Indicates if HTTP-to-HTTPS redirection should be set up.
  https_redirect = var.enable_http && var.https_redirect && (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != ""))
}
