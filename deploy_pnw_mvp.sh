#!/usr/bin/env bash

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"
echo ""

# Validate all Leo projects first
echo "🔎 Running validation step before deployment..."
bash ./validate_leo_projects.sh "$DEPLOYMENT_ROOT" || {
    echo "❌ Validation failed. Aborting deployment."
    exit 1
}

for dir in "$DEPLOYMENT_ROOT"/*; do
    if [ -d "$dir" ]; then
        name=$(basename "$dir")
        echo ""
        echo "🚀 Deploying: $name"
        echo "🔍 Directory: $dir"

        mkdir -p "$dir/build" "$dir/import"
        echo "📁 Ensuring build/ and import/ folders exist..."

        echo "🔗 Linking imports for $name..."
        ln -sf "$DEPLOYMENT_ROOT"/*/ "$dir/import/" 2>/dev/null || true

        echo "⚙️ Building $name..."
        if ! leo build --path "$dir" > "$DEPLOYMENT_LOGS/$name.log" 2>&1; then
            echo "❌ Build failed for $name. See $DEPLOYMENT_LOGS/$name.log"
        else
            echo "✅ Build succeeded for $name"
        fi
    fi
done
