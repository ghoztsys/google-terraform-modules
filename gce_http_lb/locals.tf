locals {
  # Convert `backend_services` list to a map using each element index as the key.
  backend_services = zipmap(range(length(var.backend_services)), var.backend_services)

  # Convert `backend_buckets` list to map using each element index as the key.
  backend_buckets = zipmap(range(length(var.backend_buckets)), var.backend_buckets)

  # Flatten a list of all health checks, each preserving information about its corresponding Backend Service.
  health_checks = flatten([
    for backend_service_index, backend_service in local.backend_services: length(lookup(backend_service, "health_checks", [])) == 0 ? [] : [
      for health_check_index, health_check in zipmap(range(length(backend_service.health_checks)), backend_service.health_checks): {
        backend_service_index = backend_service_index
        index = health_check_index
        path = lookup(health_check, "path", "/health")
        port = lookup(health_check, "port", lookup(backend_service, "protocol", "HTTP") == "HTTPS" ? 443 : 80)
      }
    ]
  ])

  # Flatten a list of health check resources created by this module ordered by their Backend Service index.
  health_check_links = [
    for backend_service_index, backend_service in local.backend_services: length(lookup(backend_service, "health_checks", [])) == 0 ? [] : [
      for health_check_index, health_check in zipmap(range(length(backend_service.health_checks)), backend_service.health_checks):
        google_compute_health_check.default["backend${backend_service_index}-health-check${health_check_index}"].self_link
    ]
  ]

  # Flatten a list of path rules for all Backend Services and Backend Buckets to be used by the auto-generated URL map.
  path_rules = concat(
    flatten([
      for backend_service_index, backend_service in local.backend_services: length(lookup(backend_service, "path_rules", [])) == 0 ? [] : [{
        service = google_compute_backend_service.default[backend_service_index].self_link
        paths = backend_service.path_rules
      }]
    ]),
    flatten([
      for backend_bucket_index, backend_bucket in local.backend_buckets: length(lookup(backend_bucket, "path_rules", [])) == 0 ? [] : [{
        service = google_compute_backend_bucket.default[backend_bucket_index].self_link
        paths = backend_bucket.path_rules
      }]
    ])
  )

  # Generate a list of all ports to allow access by GFEs per Backend Service.
  firewall_ports = { for backend_service_index, backend_service in local.backend_services:
    backend_service_index => distinct(concat(
      [ for health_check in lookup(backend_service, "health_checks", []): lookup(health_check, "port", lookup(backend_service, "protocol", "HTTP") == "HTTPS" ? 443 : 80) ],
      compact([ for backend in var.backends[backend_service_index]: lookup(backend, "port", 8080) ]),
    ))
  }

  # Indicates if HTTP-to-HTTPS redirection should be set up.
  redirect_http = var.enable_http && var.redirect_http && (length(var.ssl_domains) > 0 || (var.ssl_private_key != "" && var.ssl_certificate != ""))
}
