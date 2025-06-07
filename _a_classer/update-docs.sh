#! /usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)";
SUBDIRS=("infra/modules" "libs/terraform")

for SUBDIR in "${SUBDIRS[@]}"; do
	find "$ROOT/$SUBDIR" -type f -name 'main.tf' | while read -r file; do
		DIR="$(dirname "$file")"
		{ terraform-docs markdown table --output-file README.md --output-mode inject "$DIR";} || { echo "Failed to update: $DIR"; 	}
	done

	terraform fmt  -recursive -write=true "$ROOT/$SUBDIR"
done
