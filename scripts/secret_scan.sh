#!/bin/bash

echo "🔍 Scanning for secrets..."

PATTERNS=(
  "PRIVATE[[:space:]]KEY-----"
  "password[[:space:]]*="
  "api_key[[:space:]]*="
)

# Exclude this script, .git, and submodules
EXCLUDES=(
  --exclude="scripts/secret_scan.sh"
  --exclude-dir=".git"
  --exclude-dir="public"
)

FOUND=false

for pattern in "${PATTERNS[@]}"; do
  # Note: using -P for Perl regex to avoid literal self-match
  matches=$(grep -r -n -I "${EXCLUDES[@]}" -P "$pattern" .)
  if [[ -n "$matches" ]]; then
    echo "⚠️  Potential secret found matching pattern: $pattern"
    echo "$matches" | sed 's/^/   → /'
    FOUND=true
  fi
done

if [ "$FOUND" = true ]; then
  echo "❌ Commit blocked due to potential secrets."
  exit 1
else
  echo "✅ No secrets detected."
  exit 0
fi
