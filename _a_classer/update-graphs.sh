#! /usr/bin/env bash

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
STAGING_DIR="${SCRIPT_DIR}/staging"
OUT_DIR="${SCRIPT_DIR}/docs/diagrams"

mkdir -p "$OUT_DIR/dependencies"



# shellcheck disable=SC2231
for d in $STAGING_DIR/*/ ; do
  [ -L "${d%/}" ] && continue
  [[ "$d" == *"_"* ]] && continue

	PREFIX="$OUT_DIR/dependencies/$(basename "$d")"
	rm -rf "$PREFIX.svg" "$PREFIX.svg"

  echo "graphing: $(basename "$d")"

	terragrunt graph-dependencies --terragrunt-working-dir "$d" --terragrunt-include-external-dependencies \
			1> "$PREFIX.dot" 2> /dev/null

  terragrunt graph-dependencies --terragrunt-working-dir "$d" --terragrunt-include-external-dependencies | dot -Tsvg \
     	1> "$PREFIX.svg" 2> /dev/null

  echo "completed"
done
