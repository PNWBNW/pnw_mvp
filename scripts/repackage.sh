#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "📁 Ensuring build/ and output/ folders exist..."
mkdir -p build output deploy_logs

echo "📄 Loading .env variables if available..."
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "✅ Loaded NETWORK=$NETWORK and ENDPOINT=$ENDPOINT"
else
  echo "⚠️ No .env file found. Exiting..."
  exit 1
fi

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/* output/* deploy_logs/*

echo "📦 Rebuilding Leo programs and Wasm..."
leo clean
leo build --network "$NETWORK" --endpoint "$ENDPOINT"

echo "📂 Copying .aleo and .wasm files to output/..."
find build -name "*.aleo" -exec cp {} output/ \;
find build -name "*.wasm" -exec cp {} output/ \;

echo "✅ Repackage complete. Aleo + Wasm outputs are ready."
