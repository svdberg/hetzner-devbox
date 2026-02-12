terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.48"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_firewall" "devbox" {
  name = "${var.server_name}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_source_ips
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "41641"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "any"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "devbox" {
  name        = var.server_name
  server_type = var.server_type
  location    = var.location
  image       = var.image

  firewall_ids = [hcloud_firewall.devbox.id]

  user_data = <<-CLOUDINIT
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - fail2ban
      - gnupg
      - lsb-release
      - zsh

    users:
      - default
      - name: ${var.ssh_user}
        groups: [sudo, docker]
        shell: /usr/bin/zsh
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${var.ssh_public_key}

    write_files:
      - path: /etc/fail2ban/jail.d/sshd.local
        permissions: '0644'
        content: |
          [sshd]
          enabled = true
          maxretry = 5
          bantime = 1h
          findtime = 10m

      - path: /usr/local/bin/bootstrap-devbox.sh
        permissions: '0755'
        content: |
          #!/usr/bin/env bash
          set -euo pipefail

          install -m 0755 -d /etc/apt/keyrings

          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
          chmod a+r /etc/apt/keyrings/docker.gpg

          echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list

          curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(. /etc/os-release && echo $VERSION_CODENAME).noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
          curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(. /etc/os-release && echo $VERSION_CODENAME).tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list >/dev/null

          apt-get update
          DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin tailscale

          usermod -aG docker ${var.ssh_user}

          systemctl enable --now docker
          systemctl enable --now fail2ban
          systemctl enable tailscaled

          chsh -s /usr/bin/zsh ${var.ssh_user}

    runcmd:
      - /usr/local/bin/bootstrap-devbox.sh
  CLOUDINIT
}
