terraform {
  required_version = ">= 0.12.24"
}

resource "random_id" "default" {
  byte_length = 4
  keepers = {
    name = "${var.basename}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}
