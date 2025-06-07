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
# ======  kind
# ===========================================
	if ! command -v kind &>/dev/null; then
		echo "kind not found. Installing"
		go install sigs.k8s.io/kind@v0.17.0
	fi

	EXISTS=$(kind get clusters | grep -E $CLUSTER_NAME)
	[ -n "$EXISTS" ] && echo "Cluster '$EXISTS' found."

	case "$CMD" in
	destroy)
		if [[ -z "$EXISTS" ]]; then return; fi
		kind delete cluster --name "$CLUSTER_NAME"
		;;
	stop)
		if [[ -z "$EXISTS" ]]; then return; fi
		# kind delete cluster --name "$CLUSTER_NAME";
		;;
	start)

		;;
	create)
		if [[ -n "$EXISTS" ]]; then return; fi
		kind create cluster --name "$CLUSTER_NAME" --image kindest/node:v1.25.3
		kubectl config use-context "kind-$CLUSTER_NAME"
		kubectl cluster-info
		;;
	esac
# ===========================================

source "$ROOT/scripts/hooks.sh" --on-script-end