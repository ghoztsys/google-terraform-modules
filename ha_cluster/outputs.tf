output "db_public_ips" {
  description = "Public IPs of created VM instances for the database service."
  value = [
    google_compute_instance.db[*].network_interface[0].access_config[0].assigned_nat_ip,
  ]
}

output "master_public_ips" {
  description = "Public IPs of created VM instances for the master service."
  value = [
    google_compute_instance.master[*].network_interface[0].access_config[0].assigned_nat_ip
  ]
}

output "node_public_ips" {
  description = "Public IPs of the created VM instances for the node service."
  value = [
    google_compute_instance.node[*].network_interface[0].access_config[0].assigned_nat_ip,
  ]
}

output "public_ip" {
  description = "Public IP of the created VM instance for the load balancer service."
  value       = google_compute_instance.lb.network_interface[0].access_config[0].assigned_nat_ip
}

output "service_id" {
  description = "Service ID of the module."
  value       = var.service_id
}
