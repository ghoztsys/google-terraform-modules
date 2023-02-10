# Create the Kubernetes cluster.
resource "google_container_cluster" "default" {
  cluster_ipv4_cidr  = var.cluster_ipv4_cidr
  initial_node_count = var.node_count
  location           = var.region_zone
  name               = var.name
  network            = var.network
  project            = var.project_id

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  node_config {
    labels          = var.labels
    machine_type    = var.machine_type
    oauth_scopes    = var.service_scopes
    service_account = var.service_account
    tags            = concat(var.tags, [var.name], values(var.labels))
  }

  # Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 90"
  }
}

# Set named ports for created instance group. Note that this requires the gcloud
# CLI installed on the host.
resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "gcloud compute instance-groups set-named-ports ${google_container_cluster.default.node_pool[0].managed_instance_group_urls[0]} --named-ports=${var.port_name}:${var.port}"
  }
}
