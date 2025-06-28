#!/bin/bash
HOOK=".git/hooks/pre-commit"
echo "Installing pre-commit hook to run secret scan..."

cat <<'EOF' > $HOOK
#!/bin/bash
echo "Running secret scan before commit..."
./scripts/secret_scan.sh
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "❌ Commit blocked due to potential secrets."
  exit 1
fi
EOF

chmod +x $HOOK
echo "✅ Pre-commit hook installed."
