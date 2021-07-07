output client_certificate {
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
  sensitive = true
  value = google_container_cluster.default.master_auth[0].client_certificate
}

output client_key {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint."
  sensitive = true
  value = google_container_cluster.default.master_auth[0].client_key
}

output cluster_ca_certificate {
  description = "Base64 encoded public certificate that is the root of trust for the cluster."
  sensitive = true
  value = google_container_cluster.default.master_auth[0].cluster_ca_certificate
}

output host {
  description = "The IP address of this cluster's Kubernetes master."
  sensitive = true
  value = google_container_cluster.default.endpoint
}

output instance_group_urls {
  description = "List of instance group URLs which have been assigned to the cluster."
  value = google_container_cluster.default.instance_group_urls
}

output name {
  description = "Name of the created Kubernetes cluster."
  value = google_container_cluster.default.name
}

output port {
  description = "Port in the K8s cluster that is exposed to the external network."
  value = var.port
}

output port_name {
  description = "Name of the port in the K8s cluster that is exposed to the external network."
  value = var.port_name
}
