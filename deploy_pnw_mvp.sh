#!/usr/bin/env bash

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"
echo ""

# Validate environment
if [[ -z "$DEPLOYMENT_ROOT" || -z "$DEPLOYMENT_LOGS" || -z "$NETWORK" ]]; then
  echo "❌ Missing environment variables. Aborting."
  exit 1
fi

# Loop through each contract directory
for project_path in "$DEPLOYMENT_ROOT"/*; do
  if [[ -d "$project_path" ]]; then
    project_name=$(basename "$project_path")
    echo "🚀 Deploying: $project_name"
    echo "🔍 Directory: $project_path"

    cd "$project_path" || {
      echo "❌ Could not enter directory: $project_path"
      continue
    }

    LOG_FILE="$DEPLOYMENT_LOGS/${project_name}_log.txt"

    echo "📁 Ensuring import/ and build/ folders exist..."
    mkdir -p import build

    echo "📝 Writing .env file for Leo"
    echo "NETWORK=$NETWORK" > .env

    echo "🔗 Linking imports for $project_name..."
    ln -sf import/* . 2>/dev/null || true

    echo "⚙️ Building $project_name..."
    leo build --network "$NETWORK" >> "$LOG_FILE" 2>&1 || {
      echo "❌ Build failed for $project_name. See log: $LOG_FILE"
      continue
    }

    echo "✅ Build succeeded for $project_name"

    echo "🚢 Deploying $project_name to $NETWORK..."
    leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" >> "$LOG_FILE" 2>&1 || {
      echo "❌ Deploy failed for $project_name. See log: $LOG_FILE"
      continue
    }

    echo "✅ Deployed $project_name successfully"
    echo ""
  fi
done

echo "✅ Deployment process complete."
