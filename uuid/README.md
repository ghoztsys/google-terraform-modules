# `uuid`

This module generates a UUID from `basename` and `environment`. The resulting UUID is `<basename>-<8-char-hex>` if `environment` is `production`, or `<basename>-<3-char-env>-<8-char-hex>` for all other environments.
