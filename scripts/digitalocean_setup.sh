#!/bin/bash
# Setup AthensArea stack on a Debian 12 server (e.g., DigitalOcean)
# Usage: sudo bash digitalocean_setup.sh [REPO_URL] [TARGET_DIR]
# Default REPO_URL is https://github.com/youruser/athensarea.git
# Default TARGET_DIR is /opt/athensarea
set -euo pipefail

# repo to clone (defaults to your fork of this repo)
REPO_URL=${1:-https://github.com/youruser/athensarea.git}
# directory to clone into
TARGET_DIR=${2:-/opt/athensarea}

DEPLOY_USER=${SUDO_USER:-$(whoami)}

apt-get update
apt-get install -y git ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \"$(lsb_release -cs)\" stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

if ! id -nG "$DEPLOY_USER" | grep -qw docker; then
  usermod -aG docker "$DEPLOY_USER"
fi

if [ ! -d "$TARGET_DIR" ]; then
  git clone "$REPO_URL" "$TARGET_DIR"
fi
cd "$TARGET_DIR"
git pull
git config --global --add safe.directory "$TARGET_DIR"
git config --global --add safe.directory "$TARGET_DIR/public"
git submodule update --init --recursive
(cd public && git checkout production && git pull origin production || true)

SERVICE_FILE=/etc/systemd/system/directus-stack.service
install -m 644 scripts/directus-stack.service "$SERVICE_FILE"
sed -i "s|WorkingDirectory=/vagrant|WorkingDirectory=$TARGET_DIR|" "$SERVICE_FILE"

systemctl daemon-reload
systemctl enable directus-stack.service
systemctl restart directus-stack.service

echo "✅ Deployment complete. Directus should be running."
