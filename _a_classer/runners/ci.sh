#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname "$SCRIPT_DIR")/hooks.sh" --on-script-start


CMD="$1";
LOCAL=1
ARGS="";

for ARG in $@; do
	case "$ARG" in
		--local) LOCAL=1 ;;
		*) ARGS="$ARGS $ARG";;
	esac
done


# Overrides .gitlab-ci.yml as the default git ci/cd file
export GCL_NEEDS='true'
#export GCL_FILE='.gitlab-ci-local.yml' >> ~/.bashrc
#export GLC_VARIABLES="IMAGE=someimage SOMEOTHERIMAGE=someotherimage"


if [[ $LOCAL -gt 0 ]]; the
	case "$CMD" in
		preview) gitlab-ci-local $ARGS > .gitlab-ci-local/preview.yml ;;
		*) gitlab-ci-local $ARGS; ;;
	esac
else
	echo "Unable to understand your command ($@). Please try again."
fi




source "$ROOT/scripts/hooks.sh" --on-script-end