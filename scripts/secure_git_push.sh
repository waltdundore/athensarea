#!/bin/bash
echo "🔐 Checking Vault encryption..."
if ansible-vault view ansible/group_vars/all/vault.yml >/dev/null 2>&1; then
  echo "✅ Vault is encrypted. Proceeding with push."
else
  echo "❌ Vault is NOT encrypted. Encrypting..."
  ansible-vault encrypt ansible/group_vars/all/vault.yml
fi
git add .
git commit -m "secure push"
git pull --rebase
git push
