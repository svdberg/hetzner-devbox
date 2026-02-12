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

variable "server_type" {
  description = "Hetzner server type, e.g. cpx21"
  type        = string
  default     = "cpx21"
}

variable "location" {
  description = "Hetzner location, e.g. fsn1, nbg1, hel1"
  type        = string
  default     = "fsn1"
}

variable "image" {
  description = "OS image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_user" {
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
