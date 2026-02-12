# Repository conventions

- Keep infrastructure changes small, explicit, and reproducible.
- Prefer Terraform `templatefile()` for cloud-init content instead of inline heredocs.
- Run `terraform fmt` and `terraform validate` in `terraform/` before committing.
- Document operator workflows in `README.md` whenever behavior changes.
- **Do not commit secrets** (API tokens, Tailscale auth keys, private keys, or populated `.tfvars` files).
