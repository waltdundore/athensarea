
# Makefile for AthensArea.net
# Supports dual deployment: Vagrant-based or direct Docker Compose

VAULT_FILE=ansible/group_vars/all/vault.yml
VAULT_PASS=.vault_pass.txt

.PHONY: setup clean vault-encrypt vault-decrypt vault-check publish \
        deploy vagrant-deploy docker-deploy test lint directus-setup docker-scan

## 🔧 Initial setup: permissions, hooks, submodules
setup:
	chmod +x scripts/*.sh
	./scripts/install_precommit_hook.sh
	git submodule init
	git submodule update
	@echo "✅ Setup complete: permissions, hooks, submodules."

## 🧹 Clean working files
clean:
	rm -rf .vagrant *.retry __pycache__ logs/*.log

## 🚀 Smart deploy: chooses Vagrant or Docker Compose based on project context
deploy:
	@if [ -d ".vagrant" ]; then \
		make vagrant-deploy; \
	else \
		make docker-deploy; \
	fi

## 🖥️ Deploy with Vagrant and Ansible into VM
vagrant-deploy:
	@echo "📦 Starting VM and deploying inside Vagrant..."
	vagrant up --provider=parallels
	vagrant ssh -c 'cd /vagrant && make docker-deploy'

## 🐳 Deploy using Docker Compose (no VM)
docker-deploy:
	@echo "🐳 Deploying via Docker Compose..."
	docker-compose up --build -d

## 🔐 Encrypt vault
vault-encrypt:
	ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🔓 Decrypt vault
vault-decrypt:
	ansible-vault decrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS)

## 🕵️ Check if vault is encrypted
vault-check:
	@echo "🔐 Checking vault encryption..."
	@if ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "✅ Vault is encrypted."; \
	else \
		echo "❌ Vault is NOT encrypted."; \
	fi

## 🚀 Publish changes (auto-encrypts vault, runs secret scan)
publish:
	@echo "🔐 Verifying vault encryption..."
	@if ! ansible-vault view $(VAULT_FILE) --vault-password-file=$(VAULT_PASS) > /dev/null 2>&1; then \
		echo "⚠️ Vault is NOT encrypted. Auto-encrypting now..."; \
		ansible-vault encrypt $(VAULT_FILE) --vault-password-file=$(VAULT_PASS); \
	fi
	@echo "📦 Staging all changes..."
	git add .
	git status
	@read -p '✍️ Enter commit message: ' msg; \
	echo "Running secret scan before commit..."; \
	chmod +x scripts/secret_scan.sh && ./scripts/secret_scan.sh && \
	git commit -m "$$msg" && git push || echo "❌ Commit blocked due to potential secrets."

## 🔄 Update submodule content
update-public:
	@echo "🔄 Updating public/ submodule..."
	@cd public && \
		BRANCH=$$(git remote show origin | awk '/HEAD branch/ {print $$NF}'); \
		echo "📦 Detected submodule branch: $$BRANCH"; \
		git fetch origin && \
		git checkout $$BRANCH && \
		git pull origin $$BRANCH
	@echo "✅ Submodule updated."

## ✅ Linting for YAML/Ansible files
lint:
	ansible-lint playbook.yml || yamllint ansible/

## 🧪 Run CI tests (placeholder)
test:
	@echo "🧪 Running Ansible syntax check..."
	ansible-playbook playbook.yml --syntax-check

## 🚀 Setup Directus in Docker
directus-setup:
	@echo "⚙️ Starting Directus..."
	docker-compose -f docker-compose.yml up -d directus

## 🛡️ Scan Docker image (future Snyk/Docker Scout integration)
docker-scan:
	@echo "🔍 Scanning Docker images for vulnerabilities..."
	echo "(Placeholder) Use Docker Scout or Snyk CLI here"
