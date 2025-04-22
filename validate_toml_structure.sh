#!/bin/bash

echo "🔎 Validating leo.toml structure and main.leo presence..."

ROOT_DIR="./src"
FAILED=0

for contract in "$ROOT_DIR"/*; do
  if [ -d "$contract" ]; then
    echo "🧪 Checking: $contract"
    
    TOML_FILE="$contract/leo.toml"
    MAIN_FILE="$contract/main.leo"

    if [ ! -f "$TOML_FILE" ]; then
      echo "❌ Missing leo.toml in $contract"
      FAILED=$((FAILED + 1))
      continue
    fi

    if ! grep -q 'main *= *"main\.leo"' "$TOML_FILE"; then
      echo "❌ Incorrect or missing main = \"main.leo\" in $TOML_FILE"
      FAILED=$((FAILED + 1))
    fi

    if [ ! -f "$MAIN_FILE" ]; then
      echo "❌ Missing main.leo file in $contract"
      FAILED=$((FAILED + 1))
    fi
  fi
done

if [ "$FAILED" -eq 0 ]; then
  echo "✅ All leo.toml files correctly reference main.leo and files are present."
else
  echo "⚠️ Validation completed with $FAILED issue(s)."
  exit 1
fi
