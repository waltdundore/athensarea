#!/bin/bash
# secret_scan.sh - scans the project for potentially sensitive content

PATTERNS=("PRIVATE KEY-----" "password=" "api_key=")
FILES=$(git ls-files | grep -v 'scripts/secret_scan.sh')

echo "🔍 Scanning for secrets..."

FOUND=0
for file in $FILES; do
  for pattern in "${PATTERNS[@]}"; do
    if grep -q -E -- "$pattern" "$file"; then
      echo "⚠️  Potential secret found matching pattern: $pattern"
      echo "   → $file"
      FOUND=1
    fi
  done
done

if [ "$FOUND" -eq 1 ]; then
  echo "❌ Commit blocked due to potential secrets."
  exit 1
else
  echo "✅ No secrets detected."
fi
