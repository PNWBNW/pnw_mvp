#!/bin/bash

echo "🔍 Checking and Configuring PNW-MVP Directory..."

# Define the correct root directory
PNW_DIR="$HOME/pnw_mvp/Directory"

# Ensure PNW-MVP Directory exists
if [ -e "$PNW_DIR" ] && [ ! -d "$PNW_DIR" ]; then
    echo "⚠️ Warning: $PNW_DIR exists as a file. Removing..."
    rm -f "$PNW_DIR"
fi

# Create PNW-MVP Directory if it doesn't exist
mkdir -p "$PNW_DIR"

# Ensure subdirectories exist for contract deployments and logs
mkdir -p "$PNW_DIR/contracts"
mkdir -p "$PNW_DIR/logs"

# Verify directory structure
echo "✅ PNW-MVP directory is properly set up at: $PNW_DIR"
ls -la "$PNW_DIR"

echo "✅ Contracts directory: $PNW_DIR/contracts"
ls -la "$PNW_DIR/contracts"

echo "✅ Logs directory: $PNW_DIR/logs"
ls -la "$PNW_DIR/logs"

# Ensure correct permissions
chmod 700 "$PNW_DIR"

echo "🚀 PNW-MVP directory setup complete!"
