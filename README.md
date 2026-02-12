# Hetzner Devbox (Terraform + cloud-init + Tailscale)

Provision a secure, reproducible Ubuntu LTS devbox on Hetzner Cloud with Terraform.

This scaffold creates:
- a single Hetzner server
- a managed Hetzner SSH key resource
- a Hetzner firewall
- cloud-init bootstrap for a ready-to-code environment
- Docker Engine + Compose plugin
- Tailscale (manual or automated auth mode)
- SSH hardening, UFW baseline, and fail2ban

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- Hetzner Cloud project + API token
- SSH public key content (e.g. `~/.ssh/id_ed25519.pub`)
- Optional: Tailscale auth key (ephemeral or reusable)

## Quick start

```bash
cd terraform
```

### 1) Export required secret(s)

Use environment variables so secrets are never committed:

```bash
export TF_VAR_hcloud_token="<your_hetzner_token>"
# Optional for full auto Tailscale auth:
export TF_VAR_tailscale_auth_key="<your_tailscale_auth_key>"
```

### 2) Create local tfvars (non-secret config)

```bash
cat > terraform.tfvars <<'VARS'
server_name    = "devbox"
location       = "fsn1"
server_type    = "cpx21"
image          = "ubuntu-24.04"
timezone       = "Etc/UTC"
admin_user     = "devbox"
ssh_public_key = "ssh-ed25519 AAAA... you@example.com"

# Keep broad for first boot, then tighten later
ssh_source_ips = ["0.0.0.0/0", "::/0"]
VARS
```

### 3) Initialize, format, validate, apply

```bash
terraform init
terraform fmt -check
terraform validate
terraform apply
```

### 4) Connect

```bash
terraform output server_ipv4
terraform output ssh_command
```

Use output command directly:

```bash
$(terraform output -raw ssh_command)
```

## What cloud-init configures

On first boot, cloud-init:

- installs dev packages: `git curl ca-certificates build-essential python3 python3-venv python3-pip golang tmux zsh htop ripgrep fd-find ufw fail2ban`
- installs Docker Engine + Compose plugin from Docker’s official apt repo
- installs Tailscale from Tailscale’s official apt repo
- creates `admin_user` with sudo and docker group membership
- applies SSH hardening:
  - password auth disabled
  - root login disabled
  - X11 forwarding disabled
  - TCP forwarding allowed
- enables `docker`, `fail2ban`, and `tailscaled`
- configures UFW safely:
  - default deny incoming
  - default allow outgoing
  - allow `22/tcp` during bootstrap so first login remains possible

## Tailscale modes

### Mode A: Manual auth (default)

If `tailscale_auth_key` is unset, server installs/enables tailscaled but does **not** join tailnet automatically.

After first SSH login:

```bash
sudo tailscale up
tailscale status
```

### Mode B: Fully automated auth

If you set `TF_VAR_tailscale_auth_key`, cloud-init runs:

```bash
tailscale up --authkey=<key> --hostname=<server_name>
```

Verify:

```bash
ssh <admin_user>@<server_name>   # if MagicDNS enabled
tailscale status
```

## Connect from Zed over SSH

In Zed SSH target, use either:

- MagicDNS hostname: `<server_name>` (recommended)
- Tailscale IP: `100.x.y.z`

Example SSH config entry:

```sshconfig
Host devbox-ts
  HostName devbox
  User devbox
  IdentityFile ~/.ssh/id_ed25519
```

Then connect Zed to `devbox-ts`.

## Enable MagicDNS

In Tailscale admin console:

1. Open **DNS** settings.
2. Enable **MagicDNS**.
3. Reconnect or run `tailscale up` again if needed.

## Hardening after Tailscale is confirmed

Once `tailscale status` shows the node online and you can connect over Tailscale:

### Host-level lockdown (UFW)

A helper script is included on the server:

```bash
sudo /usr/local/bin/tailscale-lockdown.sh
```

This allows SSH only on `tailscale0` and removes generic port 22 allow rule.

### Perimeter-level lockdown (Hetzner firewall)

Optionally remove public SSH by changing `ssh_source_ips` to trusted CIDRs only (or to private ranges you control) and re-apply:

```bash
terraform apply
```

## Troubleshooting

### cloud-init did not complete

```bash
sudo cloud-init status --wait
sudo tail -n 200 /var/log/cloud-init-output.log
sudo journalctl -u cloud-init -u cloud-config -u cloud-final --no-pager
```

### Tailscale not connected

```bash
sudo systemctl status tailscaled --no-pager
sudo tailscale status
sudo tailscale up
```

### SSH access issues

```bash
sudo ss -tulpn | rg ':22'
sudo ufw status verbose
sudo journalctl -u ssh --no-pager -n 100
```

## Destroy

```bash
terraform destroy
```
