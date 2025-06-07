#! /usr/bin/env bash

ROOT_DIR="$(git rev-parse --show-toplevel)"
ISTIO_DIR=dirname "$(which istioctl)"
FROM_CLUSTER="$1"
TO_CLUSTER="$2"

if [[ -z "$FROM_CLUSTER" ]] || [[ -z "$TO_CLUSTER" ]]; then
	echo "clusters must be specified './k8s-clone.sh [FROM] [TO]'"
	exit 1
fi

echo "$FROM_CLUSTER => $TO_CLUSTER"
"$ROOT_DIR"/scripts/k8s-export.sh "$FROM_CLUSTER"

export KUBECONFIG="${ROOT_DIR}/config/.kube/$TO_CLUSTER.config"

SRC="${ROOT_DIR}/docs/manifests/$FROM_CLUSTER"
DIST="${ROOT_DIR}/docs/manifests/$TO_CLUSTER"



istioctl install --set profile=$TO_CLUSTER -y
kubectl apply -f ${ISTIO_DIR}/../samples/addons

kubectl apply -f "$SRC/namespaces.yaml"


istioctl

