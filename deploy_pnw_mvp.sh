#!/usr/bin/env bash
set -e

echo "🔥 Starting PNW-MVP Deployment Process..."

if [[ -z "$DEPLOYMENT_ROOT" || -z "$DEPLOYMENT_LOGS" || -z "$NETWORK" || -z "$ALEO_PRIVATE_KEY" ]]; then
  echo "❌ Missing required environment variables. Make sure DEPLOYMENT_ROOT, DEPLOYMENT_LOGS, NETWORK, and ALEO_PRIVATE_KEY are set."
  exit 1
fi

echo "🌍 Using network: $NETWORK"
mkdir -p "$DEPLOYMENT_LOGS"

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
  IMPORT_DIR="$DIR/imports"

  echo ""
  echo "🚀 Deploying: $CONTRACT"
  echo "🔍 Directory: $DIR"

  if [ ! -f "$DIR/leo.toml" ] || [ ! -f "$DIR/main.leo" ]; then
    echo "❌ Missing leo.toml or main.leo in $DIR"
    continue
  fi

  cd "$DIR" || { echo "❌ Failed to cd into $DIR"; continue; }

  echo "📁 Ensuring build/ and imports/ folders exist..."
  mkdir -p build "$IMPORT_DIR"

  echo "🔗 Linking imports for $CONTRACT..."
  for DEP in "${CONTRACTS[@]}"; do
    if [[ "$DEP" != "$CONTRACT" ]]; then
      DEP_SOURCE_REL="../../$DEP"
      ln -sf "$DEP_SOURCE_REL" "$IMPORT_DIR/$DEP"
    fi
  done

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
