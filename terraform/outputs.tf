output "server_ipv4" {
  description = "Public IPv4 address of the devbox"
  value       = hcloud_server.devbox.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect to the devbox"
  value       = "ssh ${var.admin_user}@${hcloud_server.devbox.ipv4_address}"
}

output "next_steps" {
  description = "Post-provisioning hint"
  value       = "If tailscale_auth_key was not set, SSH in and run: sudo tailscale up"
}
