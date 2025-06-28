# 🚀 Makefile for AthensArea.net — Mission-Ready Edition
# Dual deployment: Vagrant VM or local Docker Compose

VAULT_FILE = ansible/group_vars/all/vault.yml
VAULT_PASS = .vault_pass.txt
REQUIRED_SECRETS = secrets/db_password.txt secrets/directus_key.txt secrets/directus_secret.txt

.PHONY: setup clean vault-encrypt vault-decrypt vault-check publish \
        deploy vagrant-deploy docker-deploy test lint directus-setup docker-scan \
        vm-up vm-ssh dev-up dev-upd vm-reset logs update-public check-secrets

## 🔧 Initial setup: permissions, hooks, submodules
setup:
	@echo "🔧 Running initial setup..."
	@chmod +x scripts/*.sh
	@./scripts/install_precommit_hook.sh
	@git submodule update --init --recursive
	@echo "✅ Setup complete."

## 🧹 Clean all working files and artifacts
clean:
	@echo "🧹 Cleaning environment..."
	@rm -rf .vagrant *.retry __pycache__ logs/*.log
	@echo "✅ Clean complete."

## ☁️ Start the Vagrant development VM
vm-up:
	@vagrant up --provider=parallels

## 🔐 SSH into the Vagrant VM
vm-ssh:
	@vagrant ssh

## 🚀 Start Docker Compose inside Vagrant (foreground)
dev-up:
	@vagrant ssh -c 'cd /vagrant && docker compose up'

## 🔁 Rebuild and run Docker Compose inside Vagrant (detached)
dev-upd:
	@vagrant ssh -c 'cd /vagrant && docker compose up --build -d'

## 💣 Destroy the Vagrant VM and clear cache
vm-reset:
	@vagrant halt || true
	@vagrant destroy -f || true
	@rm -rf .vagrant
	@echo "💥 Vagrant environment destroyed."

## 📄 Stream Directus logs from inside Vagrant
logs:
	@vagrant ssh -c 'cd /vagrant && docker compose logs -f'

## 🛡️ Validate all required Docker secrets exist
check-secrets:
	@echo "🔐 Validating Docker secrets..."
	@for f in $(REQUIRED_SECRETS); do \
		if [ ! -f "$$f" ]; then \
			echo "❌ Missing secret: $$f"; \
			exit 1; \
		fi; \
	done
	@echo "✅ All required secrets are present."

## 🚀 Deploy based on context (prefers Vagrant if present)
deploy: check-secrets
	@if [ -d ".vagrant" ]; then \
		make update-public && make vagrant-deploy; \
	else \
		make update-public && make docker-deploy; \
	fi

## 🖥️ Deploy via Vagrant and Ansible
vagrant-deploy:
	@echo "📦 Provisioning inside Vagrant..."
	@vagrant up --provider=parallels
	@vagrant ssh -c 'cd /vagrant && make docker-deploy'

## 🐳 Deploy using Docker Compose (host)
docker-deploy: check-secrets
	@echo "🐳 Deploying via Docker Compose..."
	@docker compose up --build -d || { echo '❌ Docker Compose failed.'; exit 1; }

## 🔐 Encrypt vault file
vault-encrypt:
	@ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🔓 Decrypt vault file
vault-decrypt:
	@ansible-vault decrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🕵️ Verify if vault is encrypted
vault-check:
	@echo "🔐 Checking vault encryption..."
	@if ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "✅ Vault is encrypted."; \
	else \
		echo "❌ Vault is NOT encrypted."; exit 1; \
	fi

## 🚀 Publish Git changes with preflight checks
publish:
	@echo "🔐 Verifying vault encryption..."
	@if ! ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "⚠️ Vault is NOT encrypted. Auto-encrypting..."; \
		ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS); \
	fi
	@echo "📦 Staging all changes..."
	@git add .
	@git status
	@read -p '✍️ Enter commit message: ' msg; \
	./scripts/secret_scan.sh && \
	git commit -m "$$msg" && git push || echo "❌ Commit blocked due to potential secrets."

## 🔄 Update public/ submodule from GitHub
update-public:
	@echo "🔄 Syncing public/ submodule..."
	@cd public && \
		git fetch origin && \
		git checkout production && \
		git pull origin production
	@echo "✅ Submodule updated."

## ✅ Run linter for YAML/Ansible
lint:
	@ansible-lint playbook.yml || yamllint ansible/

## 🧪 Run syntax checks
test:
	@echo "🧪 Validating Ansible syntax..."
	@ansible-playbook playbook.yml --syntax-check

## 🚀 Start only Directus service
directus-setup:
	@echo "⚙️ Launching Directus..."
	@docker compose -f docker-compose.yml up -d directus

## 🔐 Enable systemd-managed Directus stack in Vagrant
vm-enable-directus:
	@vagrant ssh -c 'bash /vagrant/scripts/enable_directus_service.sh'

## 🛡️ Scan Docker image for vulnerabilities (placeholder)
docker-scan:
	@echo "🔍 Scanning Docker images..."
	@echo "(🛠️ TODO: Integrate Snyk or Docker Scout here)"
