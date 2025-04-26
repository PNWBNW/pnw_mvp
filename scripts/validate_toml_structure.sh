#!/usr/bin/env bash
# -----------------------------------------------------------
#  Verify each contract directory contains:
#   • leo.toml
#   • a [package].main entry
#   • the referenced main.leo file (nested or flat)
# -----------------------------------------------------------

set -euo pipefail

# Accept an explicit root path or fall back to $DEPLOYMENT_ROOT or ./src
ROOT_DIR="${1:-${DEPLOYMENT_ROOT:-./src}}"

echo "🔎  Validating leo.toml structure in ‘$ROOT_DIR’ …"
ISSUES=0

while IFS= read -r -d '' CONTRACT_DIR; do
  CONTRACT_NAME="$(basename "$CONTRACT_DIR")"
  echo "🧪  $CONTRACT_NAME"

  TOML_FILE="$CONTRACT_DIR/leo.toml"
  if [[ ! -f $TOML_FILE ]]; then
    echo "   ❌  leo.toml not found"
    ((ISSUES++))
    continue
  fi

  MAIN_PATH=$(grep -E '^[[:space:]]*main[[:space:]]*=' "$TOML_FILE" \
              | head -1 | sed -E 's/.*=["'\'']([^"'\'']+)["'\''].*/\1/')

  if [[ -z $MAIN_PATH ]]; then
    echo "   ❌  Missing ‘main = …’ entry"
    ((ISSUES++))
    continue
  fi

  FULL_PATH="$CONTRACT_DIR/$MAIN_PATH"
  # Accept either nested path or flat fallback
  if [[ -f $FULL_PATH ]]; then
    echo "   ✅  $MAIN_PATH found"
  elif [[ -f "$CONTRACT_DIR/main.leo" ]]; then
    echo "   ⚠️  Falling back to flat main.leo (update leo.toml?)"
  else
    echo "   ❌  $MAIN_PATH → file not found"
    ((ISSUES++))
  fi
done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

if [[ $ISSUES -eq 0 ]]; then
  echo "✅  All contracts passed structural validation."
else
  echo "⚠️  Validation finished with $ISSUES issue(s)."
  exit 1
fi
