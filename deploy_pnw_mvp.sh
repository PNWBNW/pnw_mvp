#!/bin/bash

set -e

if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set."
    exit 1
fi

echo "🔥 Running Pre-Deployment Build Check..."
leo clean

BUILD_LOG=$(mktemp)

if ! leo build --network testnet 2> "$BUILD_LOG"; then
    echo "🔴 Build failed. Parsing errors..."

    ERROR_DETAILS=$(grep -oE 'error: .* at [^ ]+:[0-9]+:[0-9]+' "$BUILD_LOG" || true)

    if [[ -n "$ERROR_DETAILS" ]]; then
        echo "🔍 **Parsing Error Details:**"
        echo "$ERROR_DETAILS"
    else
        echo "⚠ No specific line/column details found, check full log: $BUILD_LOG"
    fi

    exit 248
fi

echo "🔥 Starting deployment funnel for PNW-MVP..."
leo deploy --network testnet --private-key ${ALEO_PRIVATE_KEY}

echo "✅ Deployment completed successfully!"
