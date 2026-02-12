variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the devbox server"
  type        = string
  default     = "devbox"
}

variable "location" {
  description = "Hetzner location, e.g. fsn1, nbg1, hel1"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Hetzner server type, e.g. cpx21"
  type        = string
  default     = "cpx21"
}

variable "image" {
  description = "OS image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "timezone" {
  description = "Timezone to configure on the instance"
  type        = string
  default     = "Etc/UTC"
}

variable "admin_user" {
  description = "Admin username created via cloud-init"
  type        = string
  default     = "devbox"
}

variable "ssh_public_key" {
  description = "SSH public key content to inject into the admin user"
  type        = string
}

variable "ssh_source_ips" {
  description = "Allowed source IP CIDRs for SSH ingress"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "tailscale_auth_key" {
  description = "Optional Tailscale auth key for unattended tailscale up"
  type        = string
  default     = ""
  sensitive   = true
}
