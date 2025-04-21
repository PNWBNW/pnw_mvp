#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"

for CONTRACT_DIR in "$DEPLOYMENT_ROOT"/*/; do
  CONTRACT_NAME=$(basename "$CONTRACT_DIR")
  echo "🚀 Deploying: $CONTRACT_NAME"
  echo "🔍 Listing files in $CONTRACT_DIR:"
  ls -l "$CONTRACT_DIR"

  # Print leo.toml contents if available
  if [ -f "$CONTRACT_DIR/leo.toml" ]; then
    echo "📄 Content of $CONTRACT_NAME/leo.toml:"
    cat "$CONTRACT_DIR/leo.toml"
  else
    echo "⚠️  Missing leo.toml in $CONTRACT_NAME — skipping"
    continue
  fi

  cd "$CONTRACT_DIR"

  # Build and deploy
  {
    leo build --network "$NETWORK" && leo deploy --network "$NETWORK"
  } > "$DEPLOYMENT_LOGS/$CONTRACT_NAME.log" 2>&1

  # Result
  if [ $? -eq 0 ]; then
    echo "✅ Successfully deployed: $CONTRACT_NAME"
  else
    echo "❌ Failed to deploy: $CONTRACT_NAME"
    echo "📜 Deployment log for $CONTRACT_NAME:"
    cat "$DEPLOYMENT_LOGS/$CONTRACT_NAME.log"
  fi

  cd - > /dev/null
done

echo "✅ All deployments completed."
