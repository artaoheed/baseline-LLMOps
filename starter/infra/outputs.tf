output "instance_name" {
  description = "Name of the k3s VM"
  value       = google_compute_instance.k3s_node.name
}

output "public_ip" {
  description = "Public IP address — point your DuckDNS subdomain here"
  value       = google_compute_instance.k3s_node.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh ubuntu@${google_compute_instance.k3s_node.network_interface[0].access_config[0].nat_ip}"
}
