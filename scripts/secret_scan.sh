#!/bin/bash
set -euo pipefail
echo "🔍 Scanning for potential hardcoded secrets..."

# Patterns we care about
PATTERN='(AKIA[0-9A-Z]{16})'                             # AWS keys
PATTERN+='|(gh[pousr]_[A-Za-z0-9]{36,})'                 # GitHub tokens
PATTERN+='|(sk_live_[0-9a-zA-Z]{24,})'                   # Stripe live keys
PATTERN+='|-----BEGIN (RSA|DSA|EC|OPENSSH|PRIVATE) KEY-----' # PEM headers
PATTERN+='|eyJ[A-Za-z0-9_-]{10,}'                        # JWT tokens
PATTERN+='|xox[baprs]-[0-9a-zA-Z]{10,}'                  # Slack tokens

# Excluded paths (intentionally allowed secrets)
EXCLUDED_PATHS=(
  ./secrets/
  ./ansible/group_vars/all/vault.yml
)

# Build list of files to scan, ignoring excluded paths
FILES_TO_SCAN=$(find . -type f \
  ! -path "./.git/*" \
  ! -path "./.vagrant/*" \
  ! -path "./public/*" \
  ! -path "./node_modules/*" \
  ! -path "./scripts/secret_scan.sh" \
  ! -name "*.md" \
  ! -name "Makefile" \
  ! -name "vault.yml" \
  ! -path "./secrets/*" \
)

# Run scan
RESULTS=$(grep -IEn "$PATTERN" $FILES_TO_SCAN || true)

if [[ -n "$RESULTS" ]]; then
  echo "$RESULTS"
  echo "❌ Potential hardcoded secrets detected!"
  exit 1
else
  echo "✅ No secrets detected."
fi
