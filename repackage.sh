#!/bin/bash

# Set root directory where all Aleo packages live
SRC_ROOT="./src"

# Loop through each subdirectory (Aleo package)
for PACKAGE_PATH in "$SRC_ROOT"/*/; do
    PACKAGE_NAME=$(basename "$PACKAGE_PATH")

    # Skip if it's not a directory or doesn't contain a main.leo file
    if [[ ! -d "$PACKAGE_PATH" || ! -f "$PACKAGE_PATH/main.leo" ]]; then
        continue
    fi

    IMPORT_DIR="$PACKAGE_PATH/import"

    # Create the import directory if it doesn't exist
    mkdir -p "$IMPORT_DIR"

    echo "Linking imports for: $PACKAGE_NAME"

    # Link all other packages into this package's import folder
    for DEP_PATH in "$SRC_ROOT"/*/; do
        DEP_NAME=$(basename "$DEP_PATH")

        # Skip linking to itself
        if [[ "$DEP_NAME" == "$PACKAGE_NAME" ]]; then
            continue
        fi

        LINK_PATH="$IMPORT_DIR/$DEP_NAME"

        # Only create the symlink if it doesn't already exist
        if [[ ! -e "$LINK_PATH" ]]; then
            ln -s "../../$DEP_NAME" "$LINK_PATH"
            echo "  Linked: $DEP_NAME"
        fi
    done
done

echo "✅ All imports linked successfully."
