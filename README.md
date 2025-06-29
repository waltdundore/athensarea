# AthensArea.net Infrastructure

This is the development and deployment framework for [AthensArea.net](http://localhost:8055), a hyper-local content platform powered by Directus, Docker, Vagrant, and Ansible.

---

## 🚨 Quick Start (No Nonsense)

Run these commands to get the full dev stack up and running:

```bash
make setup         # One-time project setup
make vm-up         # Boot VM, build, and run Directus stack
make bootstrap-admin  # Create admin user (only once)
```

Then open your browser to: [http://localhost:8055](http://localhost:8055)

To restart from scratch:
```bash
make restart       # Destroys and rebuilds everything cleanly
```

---

## 🗺️ Overview

- **CMS:** [Directus](https://directus.io/)
- **Frontend:** Static site in `public/` (Git submodule: [athensarea-content](https://github.com/waltdundore/athensarea-content))
- **Orchestration:** Docker Compose (inside Vagrant or directly)
- **Provisioning:** Ansible
- **Secrets Management:** Docker secrets + Ansible Vault

---

## 🔧 Setup

```bash
make setup
```
- Initializes git submodules
- Installs a pre-commit secret scanning hook

---

## 🚀 Deployment Options

### Option 1: Vagrant + Docker

```bash
make vm-up
```
- Starts a Vagrant-managed Debian VM
- Syncs frontend submodule
- Builds and starts Docker stack inside VM

To rebuild everything:
```bash
make restart
```

To SSH into the VM:
```bash
make vm-ssh
```

To destroy the VM:
```bash
make vm-reset
```

### Option 2: Direct Docker Compose (No VM)

```bash
make docker-deploy
```
(Ensure Docker is installed locally, secrets are present, and ports are open)

---

## 🛠️ Maintenance

### Update frontend:
```bash
make update-public
```

### View logs:
```bash
make logs
```

### Check services:
```bash
make status
```

---

## 🔐 Secrets

Secrets are required in `secrets/`:
- `db_password.txt`
- `directus_key.txt`
- `directus_secret.txt`

To verify secrets exist:
```bash
make check-secrets
```

To check or encrypt the Ansible vault:
```bash
make vault-check
make vault-encrypt
```

---

## 🧪 Linting + Testing

```bash
make lint   # Ansible + YAML linting
make test   # Ansible syntax check
```

---

## 🧑‍💼 First-time Admin Setup

To create a Directus admin user:
```bash
make bootstrap-admin
```
Then visit [http://localhost:8055](http://localhost:8055) to log in.

---

## 🤝 Contributing

- Always commit with the vault encrypted (`make publish` helps ensure that)
- Run `make check-secrets` before pushing

---

## 📦 Roadmap

- Add optional systemd support for Directus in VM
- Enable CI/CD GitHub Actions pipeline
- Secure container scanning with Snyk or Docker Scout
- Theme Directus UI with Athens branding
