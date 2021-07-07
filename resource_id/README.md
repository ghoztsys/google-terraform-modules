# `resource_id`

This module generates a unique identifier for a cloud resource deriving from `basename` and `environment`. The resulting identifier is `<basename>-<8-char-hex>` if `environment` is `production`, or `<basename>-<3-char-env>-<8-char-hex>` for all other environments.

## Providers

1. [random](https://registry.terraform.io/providers/hashicorp/random/latest)
