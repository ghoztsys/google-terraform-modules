output "app_id" {
  description = "Service ID passed of the module."
  value = "${var.app_id}"
}

output "name" {
  description = "Name of the created Kubernetes cluster."
  value = "${google_container_cluster.default.name}"
}

output "host" {
  description = "The IP address of this cluster's Kubernetes master."
  sensitive = true
  value = "${google_container_cluster.default.endpoint}"
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
  sensitive = true
  value = "${google_container_cluster.default.master_auth.0.client_certificate}"
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint."
  sensitive = true
  value = "${google_container_cluster.default.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster."
  sensitive = true
  value = "${google_container_cluster.default.master_auth.0.cluster_ca_certificate}"
}

output "instance_group_urls" {
  description = "List of instance group URLs which have been assigned to the cluster."
  value = "${google_container_cluster.default.instance_group_urls}"
}

output "namespace" {
  description = "The namespace created to store the Kubernetes application."
  value = "${(var.namespace == "default" || var.namespace == "") ? "default" : kubernetes_namespace.default.metadata.0.name}"
}

output service_name {
  description = "Name of the default NodePort service."
  value = "${var.service_name}"
}

output service_port {
  description = "Node port of default NodePort service."
  value = "${var.service_port}"
}

output service_port_name {
  description = "Name of the opened node port."
  value = "${var.service_port_name}"
}

output target_port {
  description = "Target port for the default NodePort service."
  value = "${var.target_port}"
}

output host_port {
  description = "Host port for the default NodePort service."
  value = "${var.host_port}"
}

output "auth_username" {
  description = "Username to authenticate access to the Kubernetes cluster."
  sensitive = true
  value = "${var.auth_username}"
}

output "auth_password" {
  description = "Password to authenticate access to the Kubernetes cluster."
  sensitive = true
  value = "${var.auth_password == "" ? random_id.password.0.hex : var.auth_password}"
}
