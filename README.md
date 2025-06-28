# AthensArea.net Infrastructure

This project contains the infrastructure setup for [AthensArea.net](https://athensarea.net), including:

- 🔧 Docker/Ansible deployment
- 🖥 Vagrant-based dev environment
- 🔐 Ansible Vault secrets
- 🌐 Static content via submodule (`public/`)
- ✍️ Headless CMS via Directus (self-hosted)

---

## 📁 Repository Layout

| Path                        | Purpose                                       |
|-----------------------------|-----------------------------------------------|
| `ansible/`                  | Inventory, vaults, playbooks                  |
| `scripts/`                  | Automation scripts (secret scan, hooks, etc.) |
| `public/`                   | Static site (via submodule)                  |
| `Dockerfile` / `docker-compose.yml` | Runs Directus + frontend + Postgres     |
| `Makefile`                  | Central command hub                          |
| `vagrant-box-builder/`      | Custom box creation (optional)                |

---

## ✅ First-Time Setup

```bash
make setup
```

This will:
- Set script permissions
- Install pre-commit hook
- Initialize Git submodules

---

## 🔐 Ansible Vault

Vault secrets are stored in:

```bash
ansible/group_vars/all/vault.yml
```

To check if it’s encrypted:

```bash
make vault-check
```

To encrypt it:

```bash
make vault-encrypt
```

> A default `.vault_pass.txt` file is used (never committed). Change `password` to your own value and run:

```bash
chmod 600 .vault_pass.txt
```

---

## 🚀 Deploy to Production

```bash
make deploy
```

This runs `ansible-playbook` with secrets loaded automatically.

---

## 🔄 Pull Latest Public Content

```bash
make update-public
```

This syncs the `public/` submodule (from `athensarea-content` repo).

---

## 🧪 Secret Scanning & Linting

```bash
make secret-scan   # Scan for private keys, passwords, api_keys
make lint          # Ansible linting
```

---

## 🪪 License

This project is licensed under the **GNU GPLv3**. See `LICENSE` for full terms.