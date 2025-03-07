#!/bin/bash

set -e

if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set."
    exit 1
fi

echo "🔥 Running Pre-Deployment Build Check..."
leo clean

BUILD_LOG="build_errors.log"

# Capture the output of `leo build`
if ! leo build --network testnet 2>&1 | tee "$BUILD_LOG"; then
    echo "🔴 Parsing error detected!"
    echo "🔍 Debugging Info (First 15 Relevant Lines):"

    # Extract relevant error messages (filtering out unnecessary logs)
    grep -E "error|Error|line|column" "$BUILD_LOG" | head -n 15

    exit 248
fi

echo "🔥 Starting deployment funnel for PNW-MVP..."
leo deploy --network testnet --private-key ${ALEO_PRIVATE_KEY}

if [ $? -eq 0 ]; then
    echo "✅ All contracts deployed successfully!"
else
    echo "🔴 Deployment failed. Check logs above."
    exit 1
fi
