output "names" {
  description = "Instance names of the created clusters."
  value = ["${google_compute_instance.default.*.name}"]
}

output "public_ips" {
  description = "Public IPs of the created clusters."
  value = ["${google_compute_instance.default.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "internal_ips" {
  description = "Internal IPs of the created clusters."
  value = ["${google_compute_instance.default.*.network_interface.0.address}"]
}
