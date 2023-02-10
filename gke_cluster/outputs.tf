output "node_pool" {
  description = "List of node pools associated with the cluster."
  value       = google_container_cluster.default.node_pool
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
