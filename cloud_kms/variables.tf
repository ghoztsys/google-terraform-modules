variable "location" {
  default     = "us-central1"
  description = "Location of the Cloud KMS key ring."
  type        = string
}

variable "name" {
  default     = ""
  description = "Name of the Cloud KMS key ring and crypto key."
  type        = string
}
