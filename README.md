# Hetzner Devbox Terraform

This project provisions a Hetzner Cloud development server with:

- cloud-init bootstrap
- Docker Engine + Compose plugin
- zsh
- fail2ban
- Tailscale
- Hetzner Cloud firewall

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- A Hetzner Cloud API token
- An SSH public key (`~/.ssh/id_ed25519.pub`, for example)

## Project structure

- `terraform/main.tf` - provider, firewall, server, cloud-init
- `terraform/variables.tf` - input variables
- `terraform/outputs.tf` - useful outputs (IP + SSH command)

## Usage

1. Copy and edit tfvars:

```bash
cd terraform
cat > terraform.tfvars <<'VARS'
hcloud_token   = "<your_hcloud_token>"
ssh_public_key = "ssh-ed25519 AAAA... your@email"

# Optional overrides
server_name    = "devbox"
server_type    = "cpx21"
location       = "fsn1"
ssh_user       = "devbox"
ssh_source_ips = ["203.0.113.10/32"]
VARS
```

2. Initialize and validate:

```bash
terraform init
terraform validate
```

3. Create the devbox:

```bash
terraform apply
```

4. Get connection details:

```bash
terraform output server_ipv4
terraform output ssh_command
```

## Notes

- The cloud-init bootstrap script installs Docker from Docker's official repo.
- Tailscale is installed and `tailscaled` is enabled. Authenticate after SSH:

```bash
sudo tailscale up
```

- `fail2ban` is enabled with a basic SSH jail.

## Destroy

```bash
terraform destroy
```
