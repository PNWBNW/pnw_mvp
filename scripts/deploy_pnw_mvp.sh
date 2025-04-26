#!/usr/bin/env bash
# Fail fast, show commands & propagate failures through pipes
set -euo pipefail
IFS=$'\n\t'

echo "🔥  Starting PNW-MVP deployment"
echo "🌍  NETWORK=$NETWORK"
echo

PROJECT_ROOT="${DEPLOYMENT_ROOT:-./src}"
LOG_DIR="${DEPLOYMENT_LOGS:-./deploy_logs}"
mkdir -p "$LOG_DIR"

# --- helper : fetch local dependencies (relative paths) --------------
deps_from_toml() {
  awk '/dependencies/,//{ if ($0 ~ /path *=/) { gsub(/.*path *= *"|"/,"",$0); print $0 } }' "$1"
}

# --- build order (leaves last two payroll contracts that depend on everything else)
ORDER=(
  employer_agreement
  oversightdao_reserve
  subdao_reserve
  process_tax_compliance
  weekly_payroll_pool
  pncw_payroll
  pniw_payroll
)

for proj in "${ORDER[@]}"; do
  dir="$PROJECT_ROOT/$proj"
  [[ -d "$dir" ]] || { echo "⚠️  $proj directory not found – skipping"; continue; }

  echo "🚀  Building & deploying $proj"
  pushd "$dir" >/dev/null

  # ---- add local deps once (leo will ignore duplicates) -------------
  for dep_path in $(deps_from_toml leo.toml); do
    full_path="$PROJECT_ROOT/$dep_path"
    echo "   ➕  leo add --path $dep_path"
    leo add --path "$full_path" >/dev/null || true
  done

  # ---- build --------------------------------------------------------
  if leo build --network "$NETWORK" >>"$LOG_DIR/${proj}_build.log" 2>&1; then
    echo "   ✅  Build OK"
  else
    echo "   ❌  Build failed – check ${LOG_DIR}/${proj}_build.log"
    exit 1
  fi

  # ---- deploy -------------------------------------------------------
  if leo deploy --network "$NETWORK" --private-key "$ALEO_PRIVATE_KEY" \
        >>"$LOG_DIR/${proj}_deploy.log" 2>&1; then
    echo "   🚀  Deployed!"
  else
    echo "   ❌  Deploy failed – check ${LOG_DIR}/${proj}_deploy.log"
    exit 1
  fi

  popd >/dev/null
  echo
done

echo "🎉  All contracts built & deployed successfully!"
