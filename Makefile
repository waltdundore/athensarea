# 🚀 Makefile for AthensArea.net — Mission-Ready Edition
# Dual deployment: Vagrant VM or local Docker Compose

VAULT_FILE = ansible/group_vars/all/vault.yml
VAULT_PASS = .vault_pass.txt
REQUIRED_SECRETS = secrets/db_password.txt secrets/directus_key.txt secrets/directus_secret.txt

.PHONY: setup clean vault-encrypt vault-decrypt vault-check publish \
        deploy vagrant-deploy docker-deploy test lint directus-setup docker-scan \
        vm-up vm-ssh dev-up dev-upd vm-reset logs update-public check-secrets restart

## 🔧 Initial setup
setup:
	@echo "🔧 Running initial setup..."
	@chmod +x scripts/*.sh
	@./scripts/install_precommit_hook.sh
	@git submodule update --init --recursive
	@echo "✅ Setup complete."

## 🧹 Clean artifacts
clean:
	@echo "🧹 Cleaning environment..."
	@rm -rf .vagrant *.retry __pycache__ logs/*.log
	@echo "✅ Clean complete."

## ☁️ Start the Vagrant VM and launch Docker stack
vm-up:
	@vagrant up --provider=parallels
	@vagrant ssh -c 'cd /vagrant && git submodule update --init --recursive'
	@vagrant ssh -c 'cd /vagrant/public && git checkout production && git pull origin production || true'
	@vagrant ssh -c 'cd /vagrant && docker compose up --build -d'

## 🔐 SSH into the VM
vm-ssh:
	@vagrant ssh

## 🐳 Start Docker Compose inside VM (foreground)
dev-up:
	@vagrant ssh -c 'cd /vagrant && docker compose up'

## 🔁 Rebuild and run Docker Compose (detached)
dev-upd:
	@vagrant ssh -c 'cd /vagrant && docker compose up --build -d'

## 💣 Destroy VM and cache
vm-reset:
	@vagrant halt || true
	@vagrant destroy -f || true
	@rm -rf .vagrant
	@echo "💥 Vagrant environment destroyed."

## ♻️ Full reset and launch the environment
restart:
	@make vm-reset
	@make vm-up

## 📄 View Directus logs inside VM
logs:
	@vagrant ssh -c 'cd /vagrant && docker compose logs -f'

## 🛡️ Check for required Docker secrets
check-secrets:
	@echo "🔐 Validating Docker secrets..."
	@for f in $(REQUIRED_SECRETS); do \
		if [ ! -f "$$f" ]; then \
			echo "❌ Missing secret: $$f"; \
			exit 1; \
		fi; \
	done
	@echo "✅ All required secrets are present."

## 🚀 Smart deployment logic
deploy: check-secrets
	@if [ -d ".vagrant" ]; then \
		echo "📦 Launching deployment inside Vagrant environment..."; \
		make update-public && make vagrant-deploy; \
	else \
		echo "🐳 Launching Docker Compose directly (macOS local)..."; \
		make update-public && make docker-deploy; \
	fi

## 🖥️ Vagrant deployment
vagrant-deploy: check-secrets
	@vagrant up --provider=parallels
	@vagrant ssh -c 'cd /vagrant && make docker-deploy'

## 🐳 Docker Compose deployment
docker-deploy: check-secrets
	@echo "🐳 Deploying via Docker Compose..."
	@docker compose up --build -d || { echo '❌ Docker Compose failed. Please check the logs and try again.'; exit 1; }

## 🔐 Vault encrypt
vault-encrypt:
	@ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🔓 Vault decrypt
vault-decrypt:
	@ansible-vault decrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🔎 Vault status
vault-check:
	@echo "🔐 Checking vault encryption..."
	@if ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "✅ Vault is encrypted."; \
	else \
		echo "❌ Vault is NOT encrypted."; exit 1; \
	fi

## ✅ Secure commit + push
publish:
	@echo "🔐 Verifying vault encryption..."
	@if ! ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "⚠️ Vault is NOT encrypted. Auto-encrypting..."; \
		ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS); \
	fi
	@make check-secrets
	@echo "📦 Staging all changes..."
	@git add .
	@git status
	@read -p '✍️ Enter commit message: ' msg; \
	./scripts/secret_scan.sh && \
	git commit -m "$$msg" && git push || echo "❌ Commit blocked due to potential secrets."

## 🔄 Update public/ submodule
update-public:
	@echo "🔄 Syncing public/ submodule..."
	@cd public && \
		git fetch origin && \
		git checkout production && \
		git pull origin production
	@echo "✅ Submodule updated."

## 🧪 Ansible + YAML linting
lint:
	@ansible-lint playbook.yml || yamllint ansible/

## 🧪 Syntax check
test:
	@echo "🧪 Validating Ansible syntax..."
	@ansible-playbook playbook.yml --syntax-check

## ▶️ Start only Directus container
directus-setup:
	@echo "⚙️ Launching Directus..."
	@docker compose -f docker-compose.yml up -d directus

## 🔁 Enable systemd-managed Directus inside VM
vm-enable-directus:
	@vagrant ssh -c 'bash /vagrant/scripts/enable_directus_service.sh'

## 🛡️ Stub for container scanning
docker-scan:
	@echo "🔍 Scanning Docker images..."
	@echo "(🛠️ TODO: Integrate Snyk or Docker Scout here)"
