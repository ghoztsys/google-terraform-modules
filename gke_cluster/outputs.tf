output "managed_instance_group_urls" {
  description = "List of instance group URLs assigned to the node pool."
  value       = google_container_node_pool.default.managed_instance_group_urls
}

output "name" {
  description = "Name of the created Kubernetes cluster."
  value       = google_container_cluster.default.name
}

output "port" {
  description = "Port in the K8s cluster that is exposed to the external network."
  value       = var.port
}

output "port_name" {
  description = "Name of the port in the K8s cluster that is exposed to the external network."
  value       = var.port_name
}
