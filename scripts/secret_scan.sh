#!/bin/bash
echo "🔍 Scanning for secrets..."
PATTERNS=('PRIVATE KEY-----' 'password=' 'api_key=')
FOUND=0
FILES=$(git ls-files | grep -v 'vault.yml')
for f in $FILES; do
  for p in "${PATTERNS[@]}"; do
    if grep -qE "$p" "$f"; then
      echo "⚠️  $f contains sensitive pattern $p"
      FOUND=1
    fi
  done
done
[ $FOUND -eq 1 ] && exit 1 || echo "✅ Clean"
