#!/usr/bin/env bash

COMPLETIONS_DIR=${COMPLETIONS_DIR:-$HOME/.completion.d}
mkdir -p "$COMPLETIONS_DIR"  "$COMPLETIONS_DIR/bash"  "$COMPLETIONS_DIR/fish"  "$COMPLETIONS_DIR/zsh"  "$COMPLETIONS_DIR/pwsh" 

op completion bash  > ${COMPLETIONS_DIR}/bash/op.sh
op completion zsh   > ${COMPLETIONS_DIR}/zsh/op.sh
op completion fish  > ${COMPLETIONS_DIR}/fish/op.sh
op completion powershell > ${COMPLETIONS_DIR}/pwsh/op.ps1
