#! /usr/bin/env bash

ROOT_DIR="$(git rev-parse --show-toplevel)"

CLUSTER_NAME="$1"
if [[ -z "$CLUSTER_NAME" ]]; then
	echo "cluster name must be specified './k8s-export.sh [NAME]'"
	exit 1
fi
echo -e "\n$CLUSTER_NAME\n"

DIST="${ROOT_DIR}/docs/manifests/$CLUSTER_NAME"

export KUBECONFIG="${ROOT_DIR}/config/.kube/$CLUSTER_NAME.config"

if [[ -d "$DIST" ]]; then rm -rf "$DIST"; fi
mkdir -p "$DIST"

echo -e "\n\n$(kubectl api-resources --verbs get  --namespaced=true -o wide)\n\n"
echo -e "\n\n$(kubectl get ns -o wide)\n\n"


{
	echo -e "# $CLUSTER_NAME \n\n"
	echo -e "## Namespaces\n\n\`\`\`\n$(kubectl get ns -o wide)\n\`\`\`\n\n"
  echo -e "## Resource types\n\n\`\`\`\n$(kubectl api-resources -o wide)\n\`\`\`\n\n"
} > "$DIST/README.md"


kubectl get ns -o yaml > "$DIST/namespaces.yaml"

for ns in $(kubectl get ns -o name | sed -e "s/^namespace\///"); do
	mkdir -p "$DIST/$ns"

	for type in $(kubectl api-resources --verbs get  --namespaced=true -o name); do
		echo "[$ns] $type"
		kubectl get "$type" -n "$ns" -o yaml > "$DIST/$ns/$type.yaml"
	done
done


grep -rlI "^items: \[\]$"  "$DIST"/* | xargs -I{} rm -v {}

#      kubectl.kubernetes.io/last-applied-configuration:
#        ([\w\s-"'{}:,\./\[\]]+)
#    creationTimestamp: "([\w-"'{}:,\./\[\]]+)"
