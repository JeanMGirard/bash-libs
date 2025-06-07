#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname "$SCRIPT_DIR")/hooks.sh" --on-script-start



CLUSTER_NAME="ctn-solutions"
IS_WSL="$(uname -a | grep WSL)"
CMD="${1:-create}"
ARGS=""


while [[ $# -gt 0 ]]; do
	case "$1" in
	destroy) CMD="destroy" ;;
	create) CMD="create" ;;
	*) ARGS="$ARGS $1" ;;
	esac
	shift
done

# ===========================================
# ======  minikube
# ===========================================
	if ! command -v minikube &>/dev/null; then
		echo "minikube not found. Installing"
		curl -LOs https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
		install minikube-linux-amd64 $HOME/.local/bin/minikube
		rm minikube-linux-amd64
	fi

	EXISTS=$(minikube status $CLUSTER_NAME)
	[ -n "$EXISTS" ] && echo "Cluster '$CLUSTER_NAME' found."

	case "$CMD" in
	destroy)
		if [[ -z "$EXISTS" ]]; then return; fi
		minikube delete "$CLUSTER_NAME"
		;;
	stop)
		if [[ -z "$EXISTS" ]]; then return; fi
		minikube stop "$CLUSTER_NAME"
		;;
	create)
		if [[ -n "$EXISTS" ]]; then return; fi
		minikube start "$CLUSTER_NAME" --driver docker
		;;
	esac
# ===========================================



# ===========================================
source "$ROOT/scripts/hooks.sh" --on-script-end