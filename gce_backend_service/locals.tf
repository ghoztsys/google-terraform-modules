locals {

  # Generate a list of generated health check resource links.
  health_check_links = [ for health_check in google_compute_health_check.default: health_check.self_link ]

  # Generate a list of all ports to allow access by GFEs per Backend Service.
  firewall_ports = distinct(concat(
    [ for health_check in var.health_checks:
      lookup(health_check, "port", var.protocol == "HTTPS" ? 443 : 80)
    ],
    compact([ for backend in var.backends:
      lookup(backend, "port", 8080)
    ]),
  ))
}
