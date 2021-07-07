terraform {
  required_version = ">= 1.0.1"

  required_providers {
    random = ">= 3.1.0"
  }
}

resource "random_id" "default" {
  byte_length = 4
  keepers = {
    name = "${var.basename}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}
