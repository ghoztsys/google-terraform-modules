terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google     = ">= 4.50.0"
    kubernetes = ">= 2.7.0"
    random     = ">= 3.1.0"
    null       = ">= 3.1.0"
  }
}
