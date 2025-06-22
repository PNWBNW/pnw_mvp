#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "📁 Ensuring build/ and output/ folders exist..."
mkdir -p build output deploy_logs

echo "🧹 Cleaning previous build artifacts..."
rm -rf build/* output/* deploy_logs/*

echo "📦 Rebuilding Leo programs and Wasm..."
leo clean
leo build

echo "📂 Copying .aleo and .wasm files to output/..."
find build -name "*.aleo" -exec cp {} output/ \;
find build -name "*.wasm" -exec cp {} output/ \;

echo "✅ Repackage complete. Aleo + Wasm outputs are ready."
