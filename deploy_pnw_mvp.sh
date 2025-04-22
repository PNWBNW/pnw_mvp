#!/usr/bin/env bash

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: ${NETWORK}"

for CONTRACT_DIR in "${DEPLOYMENT_ROOT}"/*; do
  if [ -d "$CONTRACT_DIR" ]; then
    CONTRACT_NAME=$(basename "$CONTRACT_DIR")
    echo ""
    echo "🚀 Deploying: $CONTRACT_NAME"
    echo "🔍 Directory: $CONTRACT_DIR"

    cd "$CONTRACT_DIR"

    echo "📁 Ensuring build/ and imports/ folders exist..."
    mkdir -p build import

    echo "🔗 Linking imports for $CONTRACT_NAME..."
    find "$CONTRACT_DIR/import" -mindepth 1 -maxdepth 1 -type d | while read -r DEP; do
      ln -sfn "$DEP" "$CONTRACT_DIR/import/"
    done

    echo "⚙️ Building $CONTRACT_NAME..."
    if leo build --network "${NETWORK}" 2>&1 | tee "${DEPLOYMENT_LOGS}/${CONTRACT_NAME}.log"; then
      echo "✅ Build succeeded for $CONTRACT_NAME"
    else
      echo "❌ Failed to build $CONTRACT_NAME (see log above or in ${DEPLOYMENT_LOGS}/${CONTRACT_NAME}.log)"
    fi

    cd - > /dev/null
  fi
done

echo ""
echo "✅ All build attempts finished. Check logs above or in $DEPLOYMENT_LOGS"
