#!/bin/bash

set -e

if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set."
    exit 1
fi

echo "🔥 Running Pre-Deployment Build Check..."
leo clean
if ! leo build --network testnet; then
    echo "🔴 Parsing error detected. Fix syntax issues before deploying!"
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
