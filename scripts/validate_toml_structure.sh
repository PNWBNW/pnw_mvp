#!/usr/bin/env bash
# Strict validation for each Leo contract directory:
# - leo.toml must exist
# - leo.toml must have correct 'main = "src/main.leo"'
# - src/main.leo file must physically exist

set -euo pipefail

ROOT_DIR="${DEPLOYMENT_ROOT:-./src}"

echo "🔎 Strictly validating leo.toml structure in: $ROOT_DIR"
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

  if [[ "$MAIN_PATH" != "src/main.leo" ]]; then
    echo "   ❌ main must point to src/main.leo, found: $MAIN_PATH"
    ((ISSUES++))
    continue
  fi

  if [[ -f "$CONTRACT_DIR/src/main.leo" ]]; then
    echo "   ✅ src/main.leo found"
  else
    echo "   ❌ src/main.leo not found in $CONTRACT_NAME"
    ((ISSUES++))
  fi

  echo
done

if [[ $ISSUES -eq 0 ]]; then
  echo "✅ All contracts strictly validated."
else
  echo "⚠️ Validation finished with $ISSUES issue(s)."
  exit 1
fi
