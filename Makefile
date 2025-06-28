
# Makefile for AthensArea Infrastructure Project

.PHONY: help setup lint push pull vault-encrypt vault-decrypt scan testbox

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk -F: '{printf "  %-20s %s\n", $$1, $$2}'

setup:  ## Run initial vault setup
	bash scripts/setup_vault.sh

lint:  ## Run ansible-lint and yamllint
	yamllint ansible/
	find ansible -name "*.yml" -exec ansible-lint {} +

scan:  ## Scan for accidental secrets
	bash scripts/secret_scan.sh

vault-encrypt:  ## Encrypt the vault file
	ansible-vault encrypt ansible/group_vars/all/vault.yml

vault-decrypt:  ## Decrypt the vault file
	ansible-vault decrypt ansible/group_vars/all/vault.yml

push:  ## Secure push with vault encryption
	bash scripts/secure_git_push.sh

pull:  ## Secure pull with vault decryption
	bash scripts/secure_git_pull.sh

testbox:  ## Build and add a custom Debian12 Parallels Vagrant box
	cd vagrant-box-builder && bash build_box.sh
