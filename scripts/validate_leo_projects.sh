#!/usr/bin/env bash
# Build-only validation for every contract.

set -euo pipefail
ROOT="${1:-${DEPLOYMENT_ROOT:-./src}}"
echo "🔍 Validating Leo projects in: $ROOT"
echo

FAIL=0

find "$ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r DIR; do
  [[ -f "$DIR/leo.toml" ]] || continue
  echo "🛠️  leo build → $(basename "$DIR")"
  if leo build --network "$NETWORK" --path "$DIR" ; then
    echo "   ✅  build ok"; echo
  else
    echo "   ❌  build failed"; echo
    ((FAIL++))
  fi
done

[[ $FAIL -eq 0 ]] || { echo "🚨  $FAIL project(s) failed."; exit 1; }
echo "✅  All builds succeeded."
