#!/bin/bash
set -e

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"

PROJECTS=(
    "employer_agreement"
    "process_tax_compliance"
    "weekly_payroll_pool"
    "subdao_reserve"
    "oversightdao_reserve"
    "pncw_payroll"
    "pniw_payroll"
)

for project in "${PROJECTS[@]}"; do
    DIR="$DEPLOYMENT_ROOT/$project"
    echo "🚀 Deploying: $project"
    echo "🔍 Directory contents of $DIR:"
    ls -l "$DIR"

    echo "📁 Ensuring build/ and imports/ folders exist..."
    mkdir -p "$DIR/build"
    mkdir -p "$DIR/imports"

    echo "⚙️ Building $project..."
    cd "$DIR"
    leo build --network "$NETWORK"

    echo "📦 Deploying $project..."
    leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK"

    echo "✅ Successfully deployed: $project"
    echo ""
done

echo "✅ All deployments completed successfully."
