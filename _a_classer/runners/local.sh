#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname "$SCRIPT_DIR")/hooks.sh" --on-script-start

# docker compose up -d postgres

cheat(){ curl -s "cheat.sh/${1:-}"; }
alias glc='gitlab-ci-local'



source "$ROOT/scripts/hooks.sh" --on-script-end