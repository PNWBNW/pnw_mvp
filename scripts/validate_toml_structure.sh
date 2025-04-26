#!/usr/bin/env bash
# Abort on any error & echo every command (handy in CI logs)
set -euo pipefail

ROOT_DIR="${1:-./src}"

echo "🔎  Validating leo.toml structure and main.leo presence in ‘$ROOT_DIR’ …"
echo

failures=0

# Iterate over every leo.toml we can find under src/
while IFS= read -r -d '' toml; do
  dir="$(dirname "$toml")"
  name="$(basename "$dir")"
  main_file="$dir/main.leo"

  echo "🧪  $name"

  # 1.  main = "main.leo" must exist in the toml
  if ! grep -Eq '^\s*main\s*=\s*"main\.leo"\s*$' "$toml"; then
    echo "   ❌  $toml → missing or incorrect main entry"
    ((failures++))
  fi

  # 2.  main.leo must actually be there
  if [[ ! -f "$main_file" ]]; then
    echo "   ❌  $main_file → file not found"
    ((failures++))
  fi

done < <(find "$ROOT_DIR" -maxdepth 2 -type f -name 'leo.toml' -print0)

if ((failures)); then
  echo
  echo "🚨  Validation finished with $failures problem(s)."
  exit 1
fi

echo
echo "✅  Every leo.toml points to an existing main.leo – good to go!"
