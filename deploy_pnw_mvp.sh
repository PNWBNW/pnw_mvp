#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"

# Loop through each contract directory in the src folder
for CONTRACT_DIR in "$DEPLOYMENT_ROOT"/*/; do
  CONTRACT_NAME=$(basename "$CONTRACT_DIR")
  echo "🚀 Deploying: $CONTRACT_NAME"
  echo "🔍 Listing files in $CONTRACT_DIR:"
  ls -l "$CONTRACT_DIR"

  # Display leo.toml content
  if [ -f "$CONTRACT_DIR/leo.toml" ]; then
    echo "📄 Content of $CONTRACT_NAME/leo.toml:"
    cat "$CONTRACT_DIR/leo.toml"
  else
    echo "⚠️  Warning: No leo.toml found in $CONTRACT_DIR"
    continue
  fi

  # Move into contract directory
  cd "$CONTRACT_DIR"

  # If .leo directory is missing, initialize it
  if [ ! -d ".leo" ]; then
    echo "⚙️ Initializing Leo project structure for $CONTRACT_NAME"
    leo init "$CONTRACT_NAME" --quiet || echo "⚠️  leo init failed or not needed"
    mv "$CONTRACT_NAME/leo.toml" . 2>/dev/null
    mv "$CONTRACT_NAME/src/main.leo" . 2>/dev/null
    rm -rf "$CONTRACT_NAME"
  fi

  # Build and deploy
  {
    leo build --network "$NETWORK" && leo deploy --network "$NETWORK"
  } > "$DEPLOYMENT_LOGS/$CONTRACT_NAME.log" 2>&1

  # Check result
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
