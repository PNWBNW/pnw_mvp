#!/usr/bin/env bash
# Deploy every contract that passes build, adding local deps first.

set -euo pipefail

echo "🔥  Starting PNW-MVP deployment"
echo "🌍  Network: $NETWORK"
echo

get_local_deps() {      # extract “path = …” entries
  awk '/dependencies/,//{if($0 ~ /path *=/){gsub(/.*path *= *"|"/,"");print}}' "$1"
}

for DIR in "$DEPLOYMENT_ROOT"/*; do
  [[ -d $DIR && -f $DIR/leo.toml ]] || continue
  NAME=$(basename "$DIR")
  echo "🚀  Building: $NAME"

  pushd "$DIR" >/dev/null

  # Add local dependencies (if any)
  for DEP in $(get_local_deps leo.toml); do
    echo "   ➕  leo add --path $DEP"
    leo add --path "$DEP"
  done

  leo build --network "$NETWORK" --path .         # stop on failure

  echo "✅  Build ok – deploying $NAME"
  leo deploy --network "$NETWORK" --private-key "$ALEO_PRIVATE_KEY"

  popd >/dev/null
  echo
done

echo "🎉  Deployment script finished."
