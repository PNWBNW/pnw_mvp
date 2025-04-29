#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT_ROOT="${DEPLOYMENT_ROOT:-src/coordinator_program}"
DEPLOYMENT_LOGS="${DEPLOYMENT_LOGS:-deploy_logs}"

echo "🔥 Starting coordinator program deployment with .env toggles..."
mkdir -p "$DEPLOYMENT_LOGS"

# Load the .env file from coordinator_program
if [ -f "$DEPLOYMENT_ROOT/.env" ]; then
    echo "📜 Loading environment variables from $DEPLOYMENT_ROOT/.env"
    set -o allexport
    source "$DEPLOYMENT_ROOT/.env"
    set +o allexport
else
    echo "❌ .env file not found in coordinator_program."
    exit 1
fi

# List of all programs and their environment toggle names
PROGRAMS=("employer_agreement" "oversight_dao" "subdao_reserve" "pncw_payroll" "pniw_payroll" "weekly_payroll_pool" "process_tax_compliance" "payroll_audit_log")

for program in "${PROGRAMS[@]}"; do
    # Convert program name to env variable name, uppercase and underscores
    toggle_var_name=$(echo "$program" | tr '[:lower:]' '[:upper:]' | tr '-' '_' )

    # Check if the corresponding toggle is set to "true"
    if [[ "${!toggle_var_name:-false}" == "true" ]]; then
        PROGRAM_PATH="src/$program"

        if [ -d "$PROGRAM_PATH" ] && [ -f "$PROGRAM_PATH/leo.toml" ]; then
            echo "🚀 Building and deploying: $program"
            cd "$PROGRAM_PATH"

            # Clean previous builds
            echo "🧹 Cleaning..."
            leo clean || echo "⚠️ Nothing to clean, skipping."

            # Build fresh
            echo "🔨 Building fresh..."
            leo build --network testnet

            # Deploy
            echo "🛫 Deploying..."
            leo deploy --private-key "$ALEO_PRIVATE_KEY" --network testnet

            # Save deploy logs if available
            if [[ -f deploy.log ]]; then
                cp deploy.log "$GITHUB_WORKSPACE/$DEPLOYMENT_LOGS/${program}_deploy.log"
            else
                echo "⚠️ No deploy.log found for $program"
            fi

            cd - > /dev/null
        else
            echo "⚠️ Program folder or leo.toml missing for $program. Skipping."
        fi
    else
        echo "❎ Skipping $program (toggle is not enabled)"
    fi
done

# Finally, deploy the coordinator_program itself
if [ -d "$DEPLOYMENT_ROOT" ] && [ -f "$DEPLOYMENT_ROOT/leo.toml" ]; then
    echo "🚀 Building and deploying: coordinator_program"
    cd "$DEPLOYMENT_ROOT"

    # Clean previous builds
    leo clean || echo "⚠️ Nothing to clean, skipping."

    # Build fresh
    leo build --network testnet

    # Deploy
    leo deploy --private-key "$ALEO_PRIVATE_KEY" --network testnet

    if [[ -f deploy.log ]]; then
        cp deploy.log "$GITHUB_WORKSPACE/$DEPLOYMENT_LOGS/coordinator_program_deploy.log"
    else
        echo "⚠️ No deploy.log found for coordinator_program"
    fi

    cd - > /dev/null
fi

echo "✅ Deployment completed!"
