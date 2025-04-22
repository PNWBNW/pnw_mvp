#!/bin/bash
set -e

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: ${NETWORK}"

# Loop through each contract in the deployment root
for CONTRACT_DIR in "${DEPLOYMENT_ROOT}"/*; do
  if [ -d "$CONTRACT_DIR" ]; then
    CONTRACT_NAME=$(basename "$CONTRACT_DIR")
    echo ""
    echo "🚀 Deploying: $CONTRACT_NAME"
    echo "🔍 Directory: $CONTRACT_DIR"

    cd "$CONTRACT_DIR" || {
      echo "❌ Failed to access $CONTRACT_DIR"
      continue
    }

    echo "📁 Ensuring build/ and import/ folders exist..."
    mkdir -p build import

    echo "🔗 Linking imports for $CONTRACT_NAME..."
    # Link dynamic imports if needed (already handled by repackage.sh)

    echo "⚙️ Building $CONTRACT_NAME..."
    if leo build --network "${NETWORK}" 2>&1 | tee "${DEPLOYMENT_LOGS}/${CONTRACT_NAME}.log"; then
      echo "✅ Build succeeded for $CONTRACT_NAME"
    else
      echo "❌ Build failed for $CONTRACT_NAME (check ${DEPLOYMENT_LOGS}/${CONTRACT_NAME}.log)"
    fi

    cd - > /dev/null
  fi
done

echo ""
echo "✅ All build attempts finished. Check individual logs in ${DEPLOYMENT_LOGS}"
