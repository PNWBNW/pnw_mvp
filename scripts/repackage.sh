#!/bin/bash
set -e

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/ output/ deploy_logs/

echo "📦 Rebuilding Leo programs and Wasm..."
leo clean
leo build --wasm

echo "📂 Copying .aleo and .wasm files to output/..."
mkdir -p output/
find build -name "*.aleo" -exec cp {} output/ \;
find build -name "*.wasm" -exec cp {} output/ \;

echo "✅ Repackage complete. Aleo + Wasm outputs are ready."
