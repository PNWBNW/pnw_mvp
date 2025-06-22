#!/bin/bash
set -e

cd "$(dirname "$0")/.."

ROUTER_DIR="pnw_router"
MODULES=("pnw_router")  # Start with router by default

echo "📁 Ensuring build/ and output/ folders exist..."
mkdir -p build output deploy_logs

echo "📄 Loading .env from $ROUTER_DIR..."
if [ -f "$ROUTER_DIR/.env" ]; then
  export $(grep -v '^#' "$ROUTER_DIR/.env" | xargs)
  echo "✅ Loaded env from $ROUTER_DIR/.env"
else
  echo "❌ .env file not found in $ROUTER_DIR"
  exit 1
fi

# Add optional modules based on env toggles
[ "$ENABLE_PAYROLL" = "true" ] && MODULES+=("payroll")
[ "$ENABLE_TAX_LOG" = "true" ] && MODULES+=("payroll_audit_log")
[ "$ENABLE_EMPLOYER_REGISTRY" = "true" ] && MODULES+=("employer_registry")

echo "🔁 Enabled modules: ${MODULES[*]}"

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/* output/* deploy_logs/*

for MODULE in "${MODULES[@]}"; do
  echo "🔨 Building $MODULE..."
  pushd "$MODULE" > /dev/null
  leo clean
  leo build --network "$NETWORK" --endpoint "$ENDPOINT"
  cp build/*.aleo ../output/ 2>/dev/null || true
  cp build/*.wasm ../output/ 2>/dev/null || true
  popd > /dev/null
done

echo "📦 Compressing output files with gzip and generating checksums..."
for file in output/*.{aleo,wasm}; do
  [ -e "$file" ] || continue
  gzip -kf "$file"
  sha256sum "$file.gz" > "$file.gz.sha256"
  echo "✅ Compressed & checksummed: $(basename "$file")"
done

echo "✅ Full repackaging complete. Gzipped and checksummed outputs ready."
