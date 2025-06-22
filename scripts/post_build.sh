#!/bin/bash
set -e

OUTPUT_DIR="./output"

echo "📦 Gzipping and checksumming all .aleo and .wasm files in $OUTPUT_DIR"

for file in "$OUTPUT_DIR"/*.{aleo,wasm}; do
  [ -e "$file" ] || continue
  gzip -kf "$file"
  sha256sum "$file.gz" > "$file.gz.sha256"
  echo "✅ Compressed & checksummed: $(basename "$file")"
done

echo "✅ All files processed."
