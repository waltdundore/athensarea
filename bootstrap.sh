#!/usr/bin/env bash
set -euo pipefail

# 1. Install core system packages
sudo apt update
sudo apt install -y git ansible python3-pip sshpass

# 2. Optional: install Ansible collections or roles (if defined in requirements.yml)
REPO_DIR="$HOME/git/conf"
REPO_URL="https://github.com/waltdundore/conf.git"

# 3. Clone the repo
mkdir -p "$(dirname "$REPO_DIR")"
if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "[info] Repo already exists. Pulling latest changes..."
  git -C "$REPO_DIR" pull --ff-only
fi

# 4. (Optional) Create Python venv for Ansible isolation
# python3 -m venv "$REPO_DIR/.venv"
# source "$REPO_DIR/.venv/bin/activate"
# pip install --upgrade pip
# pip install -r "$REPO_DIR/requirements.txt"

# 5. Ensure inventory and config are in place
if [ ! -f "$REPO_DIR/inventory/hosts.ini" ]; then
  echo "[warning] Missing inventory file: $REPO_DIR/inventory/hosts.ini"
fi

# 6. Confirm Ansible works
ansible --version
ansible-inventory -i "$REPO_DIR/inventory/hosts.ini" --list

# 7. Optionally: Run the playbook
echo
echo "Run the following to start automation:"
echo "  cd $REPO_DIR"
echo "  ansible-playbook -i inventory/hosts.ini playbook.yml --ask-become-pass"
