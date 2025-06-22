#!/bin/bash
set -e

cd "$(dirname "$0")/.."

MODULES=("$@")  # Modules passed from deploy_pnw_mvp.sh

mkdir -p build outputs deploy_logs

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/* outputs/* deploy_logs/*

for MODULE in "${MODULES[@]}"; do
  echo "🔨 Building $MODULE..."
  pushd "$MODULE" > /dev/null
  leo clean
  leo build --network "$NETWORK" --endpoint "$ENDPOINT"
  cp build/*.aleo ../outputs/ 2>/dev/null || true
  cp build/*.wasm ../outputs/ 2>/dev/null || true
  popd > /dev/null

  echo "📦 Compressing outputs for $MODULE..."
  for file in outputs/*.{aleo,wasm}; do
    [ -e "$file" ] || continue
    gzip -kf "$file"
    sha256sum "$file.gz" > "$file.gz.sha256"
    echo "✅ Compressed & checksummed: $(basename "$file")"
  done
done

echo "✅ Selective repackaging complete."
