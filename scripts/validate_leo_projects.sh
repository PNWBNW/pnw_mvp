#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-./src}"
NETWORK="${NETWORK:-testnet}"

echo "🔍  Building all Leo projects under ‘$ROOT’ on network=$NETWORK"
echo

fails=0

while IFS= read -r -d '' toml; do
  project_dir="$(dirname "$toml")"
  project="$(basename "$project_dir")"

  echo "🛠️  leo build — $project"
  if leo build --network "$NETWORK" --path "$project_dir" \
        >"$DEPLOYMENT_LOGS/${project}_build.log" 2>&1; then
    echo "✅  Build succeeded"
  else
    echo "❌  Build FAILED – see ${DEPLOYMENT_LOGS}/${project}_build.log"
    ((fails++))
  fi
  echo
done < <(find "$ROOT" -maxdepth 2 -type f -name 'leo.toml' -print0)

if ((fails)); then
  echo "🚨  $fails project(s) failed to build."
  exit 1
fi

echo "🎉  All projects compiled successfully."
