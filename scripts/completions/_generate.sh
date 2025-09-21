#!/usr/bin/env bash

COMPLETIONS_DIR=${COMPLETIONS_DIR:-$HOME/.completion.d}
COMPLETIONS_IMPORT=${COMPLETIONS_IMPORT:-$HOME/_completions.sh}
GEN_COMPLETIONS=(
	"kubectl" 
	"helm" 
	"git"
	"vals" 
	"sops" 
	"op" 
	"gh" 
	"gcloud" 
	"aws" 
	"az"
	"istioctl"
	"flux"
	"argocd"
	"doctl"
	"terraform"
	"terragrunt"
	"yq"
	"jq"
)

# === Create completions directory structure
mkdir -p "$COMPLETIONS_DIR"  "$COMPLETIONS_DIR/bash"  "$COMPLETIONS_DIR/fish"  "$COMPLETIONS_DIR/zsh"  "$COMPLETIONS_DIR/pwsh" 


cat <<- EOF > "$COMPLETIONS_IMPORT"
# Auto-generated file, do not edit!
# Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Load completions from $COMPLETIONS_DIR
# Usage: source $COMPLETIONS_IMPORT
#
#
EOF
cat <<- 'EOF' | tee -a "$COMPLETIONS_IMPORT"
# Shell detection
SHELL_NAME="$(basename "$SHELL")"

# Load completions
if [ "$SHELL_NAME" = "bash" ] || [ "$SHELL_NAME" = "sh" ]; then
	for f in "$COMPLETIONS_DIR/bash/"*.sh; do
		[ -e "$f" ] && source "$f"
	done
elif [ "$SHELL_NAME" = "zsh" ]; then
	for f in "$COMPLETIONS_DIR/zsh/"*.sh; do
		[ -e "$f" ] && source "$f"
	done
elif [ "$SHELL_NAME" = "fish" ]; then
	for f in "$COMPLETIONS_DIR/fish/"*.fish; do
		[ -e "$f" ] && source "$f"
	done
elif [ "$SHELL_NAME" = "pwsh" ] || [ "$SHELL_NAME" = "powershell" ]; then
	for f in "$COMPLETIONS_DIR/pwsh/"*.ps1; do
		[ -e "$f" ] && . "$f"
	done
fi
EOF




for cmd in "${GEN_COMPLETIONS[@]}"; do
	if [ ! "$(command -v command)" ]; then
		echo "command \"command\" dont exists on system"
		continue
	fi
	(
		$cmd completion bash  > "${COMPLETIONS_DIR}/bash/${cmd}.sh"
		$cmd completion zsh   > "${COMPLETIONS_DIR}/zsh/${cmd}.sh"
		$cmd completion fish  > "${COMPLETIONS_DIR}/fish/${cmd}.sh"
		$cmd completion powershell > "${COMPLETIONS_DIR}/pwsh/${cmd}.ps1"
	) || echo "Failed to generate completions for ${cmd}"
done
