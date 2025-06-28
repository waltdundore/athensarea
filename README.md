# AthensArea.net

A secure, automated infrastructure project for hosting static content and Directus-powered CMS, using:

- 🔐 Ansible + Vault
- 🐳 Docker Compose
- 🧱 Vagrant for dev VM
- 🧰 Makefile-based CLI
- ⚙️ Git pre-commit hooks with secret scanning
- 📁 `public/` content synced via Git submodule

---

## 🗂️ Project Structure

```
ansible/               # Ansible inventory, vars, playbooks
public/                # Git submodule: static site content
scripts/               # Helper scripts (secret scan, vault, git)
docker-compose.yml     # Runs Directus + PostgreSQL
Makefile               # Dev automation (see below)
```

---

## 🔧 Initial Setup

1. 🔐 Create `.vault_pass.txt` with your vault password:
   ```bash
   echo "your-password" > .vault_pass.txt
   chmod 600 .vault_pass.txt
   ```

2. 🧰 Install pre-commit hook:
   ```bash
   make setup
   ```

---

## ⚙️ Makefile Commands

| Command           | Description                              |
|-------------------|------------------------------------------|
| `make setup`      | Install pre-commit hook + submodule init |
| `make deploy`     | Run Ansible deployment                   |
| `make vault-encrypt` | Encrypt vault secrets manually       |
| `make vault-decrypt` | Decrypt vault secrets manually       |
| `make vault-check`   | Check encryption status               |
| `make clean`      | Clean cache/logs/.vagrant                |
| `make publish`    | Encrypt vault, scan for secrets, push    |

---

## 🛡 Secret Scanning

Every commit runs a scan for:

- `PRIVATE KEY-----`
- `password=`
- `api_key=`

Self-references and safe paths like `scripts/` and `public/` are excluded.

If a match is found, the commit is blocked.

---

## 🔐 Ansible Vault

All secrets are stored only in:

```
ansible/group_vars/all/vault.yml
```

Use:

```bash
make vault-decrypt
make vault-encrypt
```

Vault password is read automatically from `.vault_pass.txt`.

---

## 📦 Docker Compose

Runs `directus` and `postgres` using variables and secrets:

```bash
docker-compose up -d --build
```

Secrets like `directus_key.txt` and `directus_secret.txt` live in the `secrets/` folder.

---

## 📁 Public Directory as Submodule

The static site content lives in:

```
public/ (from git@github.com:waltdundore/athensarea-content.git)
```

It’s included as a Git submodule. Update it with:

```bash
make update-public
```

---

## ☁️ Deployment

Push and deploy with:

```bash
make publish
```

This will:

- Check encryption status
- Auto-encrypt vault if needed
- Run secret scan
- Commit + push changes

---

## 🪪 License

[GNU GPLv3](LICENSE)
