# Generate random 6-character string to append to the WIF ID.
resource "random_id" "default" {
  byte_length = 3

  keepers = {
    id = var.name
  }
}

# Create KMS key ring. Note that Terraform cannot delete KMS key rings, hence
# a random hex suffix is appended to the name to avoid conflicts.
resource "google_kms_key_ring" "default" {
  location = var.location
  name     = var.name == "" ? random_id.default.hex : "${var.name}-${random_id.default.hex}"
}

# Create KMS crypto key.
resource "google_kms_crypto_key" "default" {
  key_ring = google_kms_key_ring.default.id
  name     = google_kms_key_ring.default.name
}
