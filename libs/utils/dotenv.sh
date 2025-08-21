#!/usr/bin/env bash

dotenv::load() {
  local dotenv_file="${1:-$HOME/.env}"

  if [ -f "$dotenv_file" ]; then
    eval "$(cat "$dotenv_file" | grep -v '^#' | sed 's/^\(.*\)=\(.*\)$/export \1="\2"/')"
  else
    echo "Dotenv file not found: $dotenv_file"
  fi
}
