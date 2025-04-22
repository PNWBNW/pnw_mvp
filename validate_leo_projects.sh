#!/usr/bin/env bash

ROOT="${1:-src}"
echo "🔍 Validating Leo projects in: $ROOT"
echo ""

FAILURES=0

for dir in "$ROOT"/*; do
    if [ -d "$dir" ] && [ -f "$dir/leo.toml" ] && [ -f "$dir/main.leo" ]; then
        echo "🧪 Validating: $dir"
        pushd "$dir" > /dev/null
        if ! leo build --network "$NETWORK"; then
            echo "❌ Validation failed in $dir"
            ((FAILURES++))
        else
            echo "✅ Validation succeeded in $dir"
        fi
        echo ""
        popd > /dev/null
    fi
done

if [ "$FAILURES" -gt 0 ]; then
    echo "❗ $FAILURES project(s) failed validation."
    exit 1
else
    echo "✅ All projects validated successfully."
fi
