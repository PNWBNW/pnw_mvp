#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "📁 Ensuring build/ and output/ folders exist..."
mkdir -p build output deploy_logs

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/* output/* deploy_logs/*

echo "📦 Compressing output files (if any exist)..."
for file in output/*.{aleo,wasm}; do
  [ -e "$file" ] || continue
  gzip -kf "$file"
  sha256sum "$file.gz" > "$file.gz.sha256"
  echo "✅ Compressed & checksummed: $(basename "$file")"
done

echo "📄 Handing off to deploy_pnw_mvp.sh..."
bash ./scripts/deploy_pnw_mvp.sh
