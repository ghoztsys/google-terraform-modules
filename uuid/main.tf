terraform {
  required_version = ">= 0.12.25"

  required_providers {
    random = ">= 2.2.1"
  }
}

resource "random_id" "default" {
  byte_length = 4
  keepers = {
    name = "${var.basename}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}
