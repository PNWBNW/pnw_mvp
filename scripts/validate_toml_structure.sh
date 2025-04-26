#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Validate that each contract:
#   • contains leo.toml
#   • leo.toml has a [package].main entry
#   • that file actually exists (handles nested src/ layouts)
# ---------------------------------------------------------------------------

set -euo pipefail
ROOT_DIR="${1:-./src}"

echo "🔎  Validating leo.toml structure and main.leo presence in ‘$ROOT_DIR’ …"
ISSUES=0

while IFS= read -r -d '' CONTRACT_DIR; do
  CONTRACT_NAME=$(basename "$CONTRACT_DIR")
  echo "🧪  $CONTRACT_NAME"

  TOML="$CONTRACT_DIR/leo.toml"
  if [[ ! -f $TOML ]]; then
    echo "   ❌  leo.toml not found"
    ((ISSUES++))
    continue
  fi

  # Pull the path after main = "…"
  MAIN_PATH=$(grep -E '^[[:space:]]*main[[:space:]]*=' "$TOML" \
              | head -1 \
              | sed -E 's/.*=["'\'']([^"'\'']+)["'\''].*/\1/')

  if [[ -z $MAIN_PATH ]]; then
    echo "   ❌  Missing ‘main = …’ entry in leo.toml"
    ((ISSUES++))
    continue
  fi

  FULL_PATH="$CONTRACT_DIR/$MAIN_PATH"
  if [[ ! -f $FULL_PATH ]]; then
    echo "   ❌  $MAIN_PATH → file not found"
    ((ISSUES++))
  else
    echo "   ✅  $MAIN_PATH found"
  fi
done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

if [[ $ISSUES -eq 0 ]]; then
  echo "✅  All contracts passed structural validation."
else
  echo "⚠️  Validation finished with $ISSUES issue(s)."
  exit 1
fi
