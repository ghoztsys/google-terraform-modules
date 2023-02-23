output "name" {
  description = "DNS name."
  value       = google_dns_record_set.default.name
}

output "url" {
  description = "URL."
  value       = trim(google_dns_record_set.default.name, ".")
}
