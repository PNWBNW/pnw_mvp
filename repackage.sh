#!/bin/bash
echo "📦 Repackaging dependencies for dynamic Leo imports..."

# Directory containing all contract folders
SRC_DIR="./src"

# Iterate over each contract folder
for CONTRACT_PATH in "$SRC_DIR"/*/; do
  CONTRACT_NAME=$(basename "$CONTRACT_PATH")
  IMPORT_DIR="${CONTRACT_PATH}import"

  echo "🔁 Preparing import directory for $CONTRACT_NAME..."
  mkdir -p "$IMPORT_DIR"

  # Copy all other contracts' main.leo files as .aleo files into this one's import/
  for DEP_PATH in "$SRC_DIR"/*/; do
    DEP_NAME=$(basename "$DEP_PATH")
    if [ "$DEP_NAME" != "$CONTRACT_NAME" ]; then
      cp "${DEP_PATH}main.leo" "${IMPORT_DIR}/${DEP_NAME}.aleo"
    fi
  done
done

echo "✅ All imports prepared."
