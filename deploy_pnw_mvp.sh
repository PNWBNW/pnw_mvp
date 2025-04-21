#!/usr/bin/env bash

# Exit immediately on error
set -e

echo "🔥 Starting PNW-MVP Deployment Process..."

# Ensure environment variables are set
if [[ -z "$DEPLOYMENT_ROOT" || -z "$DEPLOYMENT_LOGS" || -z "$NETWORK" || -z "$ALEO_PRIVATE_KEY" ]]; then
  echo "❌ Missing required environment variables. Make sure DEPLOYMENT_ROOT, DEPLOYMENT_LOGS, NETWORK, and ALEO_PRIVATE_KEY are set."
  exit 1
fi

echo "🌍 Using network: $NETWORK"
mkdir -p "$DEPLOYMENT_LOGS"

# Define contract list (in build order if dependencies exist)
CONTRACTS=(
  employer_agreement
  oversightdao_reserve
  pncw_payroll
  pniw_payroll
  process_tax_compliance
  subdao_reserve
  weekly_payroll_pool
)

for CONTRACT in "${CONTRACTS[@]}"; do
  DIR="$DEPLOYMENT_ROOT/$CONTRACT"
  LOG="$DEPLOYMENT_LOGS/${CONTRACT}.log"

  echo ""
  echo "🚀 Deploying: $CONTRACT"
  echo "🔍 Directory: $DIR"

  if [ ! -f "$DIR/leo.toml" ] || [ ! -f "$DIR/main.leo" ]; then
    echo "❌ Missing leo.toml or main.leo in $DIR"
    continue
  fi

  cd "$DIR" || { echo "❌ Failed to cd into $DIR"; continue; }

  echo "📁 Ensuring build/ and imports/ folders exist..."
  mkdir -p build imports

  echo "⚙️ Building $CONTRACT..."
  if leo build --network "$NETWORK" > "$LOG" 2>&1; then
    echo "✅ Successfully built $CONTRACT"
  else
    echo "❌ Failed to build $CONTRACT (check $LOG)"
    continue
  fi
done

echo ""
echo "✅ All build attempts finished. Check individual logs in $DEPLOYMENT_LOGS"
