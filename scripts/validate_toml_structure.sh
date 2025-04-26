#!/usr/bin/env bash
# Verify every contract directory contains:
# - leo.toml file
# - main = ... entry in leo.toml
# - main.leo file present as referenced

set -euo pipefail

ROOT_DIR="${DEPLOYMENT_ROOT:-./src}"

echo "🔎 Validating leo.toml structure in: $ROOT_DIR"
echo

ISSUES=0

find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r CONTRACT_DIR; do
  CONTRACT_NAME="$(basename "$CONTRACT_DIR")"
  echo "🧪 Checking: $CONTRACT_NAME"

  TOML_FILE="$CONTRACT_DIR/leo.toml"
  if [[ ! -f "$TOML_FILE" ]]; then
    echo "   ❌ leo.toml not found"
    ((ISSUES++))
    continue
  fi

  MAIN_PATH=$(grep -E '^[[:space:]]*main[[:space:]]*=' "$TOML_FILE" \
              | head -1 | sed -E 's/.*=["'\'']([^"'\'']+)["'\''].*/\1/')

  if [[ -z "$MAIN_PATH" ]]; then
    echo "   ❌ Missing main entry in leo.toml"
    ((ISSUES++))
    continue
  fi

  # Accept either nested path or flat fallback
  if [[ -f "$CONTRACT_DIR/$MAIN_PATH" ]]; then
    echo "   ✅ Found $MAIN_PATH"
  elif [[ -f "$CONTRACT_DIR/main.leo" ]]; then
    echo "   ⚠️ Fallback to flat main.leo (recommend fixing leo.toml)"
  else
    echo "   ❌ main.leo not found as referenced"
    ((ISSUES++))
  fi

  echo
done

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ All contracts structurally validated."
else
  echo "⚠️ Validation finished with $ISSUES issue(s)."
  exit 1
fi
