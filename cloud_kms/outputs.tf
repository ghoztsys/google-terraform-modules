output "key_ring" {
  description = "Cloud KMS key ring ID."
  value       = google_kms_key_ring.default.id
}

output "crypto_key" {
  description = "Cloud KMS crypto key ID."
  value       = google_kms_crypto_key.default.id
}
