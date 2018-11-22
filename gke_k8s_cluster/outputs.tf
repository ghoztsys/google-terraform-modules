output "name" {
  description = "Name of the created Kubernetes cluster."
  value = "${google_container_cluster.default.name}"
}

output "endpoint" {
  description = "The IP address of this cluster's Kubernetes master."
  value = "${google_container_cluster.default.endpoint}"
}

output "service_id" {
  description = "Service ID passed of the module."
  value = "${var.service_id}"
}

output "instance_group_urls" {
  description = "List of instance group URLs which have been assigned to the cluster."
  value = "${google_container_cluster.default.instance_group_urls}"
}
