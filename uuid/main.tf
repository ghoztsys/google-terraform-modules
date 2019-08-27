provider "random" {
  version = "~> 2.2"
}

resource "random_id" "default" {
  byte_length = 4
  keepers = {
    app_id = var.app_id
    environment = var.environment
    name = "${var.app_id}${var.environment != "production" ? format("-%.3s", var.environment) : ""}"
  }
}
