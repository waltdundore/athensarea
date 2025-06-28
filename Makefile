# Makefile for AthensArea.net Infrastructure

# ====================
# 🛠 Basic Setup Tasks
# ====================

setup:
	chmod +x scripts/*.sh
	./scripts/install_precommit_hook.sh
	git submodule init
	git submodule update
	@echo "✅ Setup complete: permissions, hooks, submodules."

# ======================
# 🔐 Vault Management
# ======================

vault-check:
	@echo "🔐 Checking vault encryption..."
	@ansible-vault view ansible/group_vars/all/vault.yml >/dev/null 2>&1 && \
	  echo "✅ Vault is already encrypted." || \
	  echo "❌ Vault is NOT encrypted."

vault-encrypt:
	ansible-vault encrypt ansible/group_vars/all/vault.yml

vault-decrypt:
	ansible-vault decrypt ansible/group_vars/all/vault.yml

# ======================
# 🚀 Ansible Deployment
# ======================

deploy:
	ansible-playbook -i ansible/inventory/hosts.ini playbook.yml --vault-password-file .vault_pass.txt

# ======================
# 🔄 Submodule Updates
# ======================

update-public:
	git submodule update --remote --merge
	@echo "✅ Public content updated from submodule."

# ============================
# 🧼 Maintenance & Linting
# ============================

lint:
	ansible-lint playbook.yml || true

secret-scan:
	scripts/secret_scan.sh

clean:
	rm -rf .vagrant *.retry __pycache__ logs/*.log

publish:
	@echo "🔐 Verifying vault encryption..."
	@grep -q "\$ANSIBLE_VAULT" ansible/group_vars/all/vault.yml && \
	  echo "✅ Vault is already encrypted." || \
	( echo "⚠️ Vault is NOT encrypted. Auto-encrypting now..."; \
	  ansible-vault encrypt ansible/group_vars/all/vault.yml )

	@echo "📦 Staging all changes..."
	git add .

	@git status
	@echo "✍️ Enter commit message:"
	@read msg; git commit -m "$$msg"

	@echo "🚀 Pushing to GitHub..."
	git push
	@echo "✅ Publish complete."


