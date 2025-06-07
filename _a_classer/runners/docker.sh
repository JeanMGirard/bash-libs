#!/usr/bin/env bash
# shellcheck disable=SC2068

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname "$SCRIPT_DIR")/hooks.sh" --on-script-start

CMD=$1
[ -n "$1" ] && shift;
[ -z "$CMD" ] && CMD="start";
CMD=${CMD//start/up}


[]
case "$CMD" in
  up) ARGS="-d postgres api $@"; ;;
	top) ARGS="$@"; ;;
  *) ARGS="$@"; ;;
esac

# clear
COMPOSE_ARGS="$(find $ROOT -maxdepth 0 -type f -iname 'docker-compose.*' -exec printf " -f %s" {} \;)"
COMPOSE_ARGS="${COMPOSE_ARGS//$(pwd)\//}"
DOCKER_ARGS="compose ${COMPOSE_ARGS}"

# echo "docker $DOCKER_ARGS ${CMD/compose//} $ARGS"

do_usage(){


}
do_run(){
	case $CMD in
  	compose) docker compose $COMPOSE_ARGS $ARGS ;;
  	args) echo "$DOCKER_ARGS" ;;
  	help) do_usage ;;
  	start)
  			docker $DOCKER_ARGS up $ARGS
  			echo -e "\n\n Environment started.\n"
  			docker $DOCKER_ARGS  ps
  			echo ""
  		;;
  	*) docker $DOCKER_ARGS $CMD $ARGS;;
  esac
}



source "$ROOT/scripts/hooks.sh" --on-script-end
