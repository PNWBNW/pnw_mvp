#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Build (and later deploy) every Leo contract under $DEPLOYMENT_ROOT
# Adds local path dependencies automatically before building.
# ---------------------------------------------------------------------------

set -euo pipefail

echo "🔥 Starting PNW-MVP Deployment Process"
echo "🌍 Network: $NETWORK"
echo "📂 Contracts root: $DEPLOYMENT_ROOT"

# Helper: extract dependency paths from [dependencies] section
deps() {
  awk '/dependencies/,//{if(/path *=/){gsub(/[[:space:]|"\047|\{|}]/,"");print $3}}' "$1"
}

for CONTRACT_DIR in "$DEPLOYMENT_ROOT"/*; do
  [[ -f "$CONTRACT_DIR/leo.toml" ]] || continue

  CONTRACT=$(basename "$CONTRACT_DIR")
  echo -e "\n🚀 Building: $CONTRACT"
  echo "📁 Directory: $CONTRACT_DIR"

  pushd "$CONTRACT_DIR" >/dev/null

  echo "🔗 Adding local dependencies…"
  for DEP_PATH in $(deps leo.toml); do
    echo "   ➕  $DEP_PATH"
    leo add --path "$DEP_PATH" >/dev/null
  done

  echo "🛠️  leo build --network $NETWORK"
  leo build --network "$NETWORK"

  popd >/dev/null
done

echo -e "\n🎉 All contracts built successfully."
