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
  value = "${google_container_cluster.default.endpoint}"
  sensitive = true
}

output "auth_username" {
  description = "Username to authenticate access to the Kubernetes cluster."
  value = "${var.auth_username}"
  sensitive = true
}

output "auth_password" {
  description = "Password to authenticate access to the Kubernetes cluster."
  value = "${var.auth_password == "" ? random_id.password.0.hex : var.auth_password}"
  sensitive = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
  value = "${google_container_cluster.default.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the cluster endpoint."
  value = "${google_container_cluster.default.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster."
  value = "${google_container_cluster.default.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "instance_group_urls" {
  description = "List of instance group URLs which have been assigned to the cluster."
  value = "${google_container_cluster.default.instance_group_urls}"
}
