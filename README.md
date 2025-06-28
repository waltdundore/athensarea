[![CI](https://github.com/waltdundore/athensarea/actions/workflows/lint-and-scan.yml/badge.svg)](https://github.com/waltdundore/athensarea/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Directus](https://img.shields.io/badge/CMS-Directus-lightgrey.svg)](https://directus.io/)
[![Dockerized](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)
[![Vagrant](https://img.shields.io/badge/VM-Vagrant-green)](https://www.vagrantup.com/)

# AthensArea.net 🚀

A fully containerized, fault-tolerant, Vagrant-integrated publishing platform built on:

- **Directus** (headless CMS)
- **Docker Compose** (multi-service stack)
- **Vagrant** + **Ansible** (infrastructure automation)
- **Git submodules** for content decoupling

---

## 🔧 Initial Setup

```bash
make setup
```

- Initializes submodules
- Installs pre-commit secret scanning hook
- Sets executable permissions on scripts

---

## 🐳 Local Development with Docker

```bash
make docker-deploy
```

- Builds and starts all services in `docker-compose.yml`
- Uses **Docker secrets**, not bind mounts

To shut down:

```bash
docker compose down
```

---

## 🖥️ Development with Vagrant + Docker

```bash
make vm-up         # Boots the VM
make dev-up        # Runs Docker Compose in foreground
make dev-upd       # Rebuilds containers (detached)
```

VM Access:

```bash
make vm-ssh        # SSH into the VM
make vm-reset      # Fully destroy and reset VM
```

---

## 🚀 Smart Deployment

```bash
make deploy
```

- Detects `.vagrant/`
  - If found → deploys inside VM
  - If not → deploys via Docker Compose
- Validates required Docker secrets

---

## 🔐 Vault Secrets Management

```bash
make vault-check     # Ensure vault is encrypted
make vault-encrypt   # Encrypt with .vault_pass.txt
make vault-decrypt   # Decrypt for editing
```

> 🔒 Ensure `.vault_pass.txt` is:
> ```bash
> chmod 600 .vault_pass.txt
> ```
> …and included in `.gitignore`.

---

## 🔄 Update `public/` Submodule

The `public/` folder is a submodule tracking [`athensarea-content`](https://github.com/waltdundore/athensarea-content).

To update content:

```bash
make update-public
```

- Automatically fetches and pulls latest production changes

---

## 🧪 Testing & Linting

```bash
make lint     # YAML + Ansible linting
make test     # Ansible syntax check
```

---

## 🔄 Secure Publish Workflow

```bash
make publish
```

- Verifies encryption
- Scans for hardcoded secrets before commit
- Prompts for message and pushes to Git

---

## 🔧 Utility Targets

```bash
make clean              # Remove logs, retries, Vagrant state
make logs               # View Directus logs inside VM
make directus-setup     # Start only Directus container
make docker-scan        # Placeholder for Docker image scanning
make vm-enable-directus # Enable systemd-managed Directus service in VM
```

---

## 🛡️ Docker Secrets Required

These files must exist before any local Docker Compose deployment:

- `secrets/db_password.txt`
- `secrets/directus_key.txt`
- `secrets/directus_secret.txt`

They're automatically validated during `make deploy`.

---

## 🪪 License

Licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0). See the [LICENSE](./LICENSE) file for full details.
