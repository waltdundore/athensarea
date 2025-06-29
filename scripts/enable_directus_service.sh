#!/bin/bash
set -e

SERVICE_PATH="/etc/systemd/system/directus-stack.service"
LOCAL_SERVICE_FILE="/vagrant/scripts/directus-stack.service"

echo "🛠️ Installing Directus systemd service..."

sudo cp "$LOCAL_SERVICE_FILE" "$SERVICE_PATH"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable directus-stack.service
sudo systemctl restart directus-stack.service

echo "✅ Directus stack service enabled and started."
