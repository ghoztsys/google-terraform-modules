terraform {
  required_version = ">= 0.13.5"

  required_providers {
    random = ">= 3.0.0"
  }
}

resource "random_id" "default" {
  byte_length = 4
  keepers = {
    name = "${var.basename}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}
