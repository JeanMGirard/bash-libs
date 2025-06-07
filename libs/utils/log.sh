##! /usr/bin/env bash

__log__APP="${IMPORT__BIN_FILE##*/}" # Strip everything before last "/"
if [[ -z "$__log__APP" ]]; then __log__APP="$( basename $(pwd) )"; fi;

__log_write(){
  local NAME="$__log__APP" COLOR="" \
  			LEVEL="" LVL_2="" \
   			BEGIN='' END='' CONTENT="";

  while [[ $# -gt 0 && -z "$LEVEL" ]]; do case "$1" in
    --log-name)  		NAME="$2";  shift; ;;
    --log-color) 		COLOR="$2"; shift; ;;
    --log-lvl 	| --log-level)   		LEVEL="$2"; shift; ;;
  	--log-lvl-* | --log-level-*)  	LVL_2="$LVL_2:$2"; shift; ;;
    fatal | FATAL) 	LEVEL="FATAL"; 	;;
    error | ERROR) 	LEVEL="ERROR"; 	;;
    warn 	| WARN) 	LEVEL="WARN"; 	;;
    info 	| INFO) 	LEVEL="INFO"; 	;;
    debug | DEBUG) 	LEVEL="DEBUG"; 	;;
    *) CONTENT="$CONTENT $1"
  esac; shift; done;
  if [[ -z "$LEVEL" ]]; then LEVEL="INFO"; fi;

  while [[ $# -gt 0 ]]; do case "$1" in
    --log-name)  NAME="$2";  shift; ;;
    --log-color) COLOR="$2"; shift; ;;
    --log-lvl 	| --log-level)   		LEVEL="$2"; shift; ;;
  	--log-lvl-* | --log-level-*)  	LVL_2="$LVL_2 $2 "; shift; ;;
    *) CONTENT="$CONTENT $1"
  esac; shift; done;

  case "$LEVEL" in
    fatal | FATAL) 	COLOR="${COLOR:-92m}"; 	;;
    error | ERROR) 	COLOR="${COLOR:-91m}"; 	;;
    warn 	| WARN) 	COLOR="${COLOR:-96m}"; 	;;
    info 	| INFO) 	COLOR="${COLOR:-92m}"; 	;;
    debug | DEBUG) 	COLOR="${COLOR:-92m}"; 	;;
    *) 							COLOR="${COLOR:-92m}"; 	;;
  esac
  LEVEL="${LEVEL^^}";  BEGIN=$'\033['; END=$'\033[39m';
  if [[ ! -z "$LVL_2" ]]; then LVL_2=$(__log_trim "${LVL_2^^}" | tr '[:upper:]' '[:lower:]'); fi

  __log_trim "| ts | ${BEGIN:-}${COLOR:-}[${LEVEL}]${END:-}[${LVL_2:-}]::($NAME) | $(__log_trim "$CONTENT")" >&2
	printf "\n"
}

log::fatal(){
	 __log_write fatal $@;
   __log_stacktrace 2;
  exit 1
}
log::error(){
	 __log_write error $@;
   __log_stacktrace 2;
}
function log::warn {
	 __log_write warn $@;
   __log_stacktrace 2;
}
function log::info {
	 __log_write info $@;
}
log::debug(){
	 __log_write debug $@;
}
function log::panic(){
  __log_enable_stacktrace
  log::fatal --log-lvl-2 "PANIC" "${*:-}"
}
function log::unimplemented(){
  __log_enable_stacktrace
   __log_write fatal --log-lvl-2 "UNIMPLEMENTED" "${*:-}"
   __log_stacktrace 2;
  exit 42
}
function log::todo {
  __log_enable_stacktrace
   __log_write --log-lvl "TODO" "${*:-}"
   __log_stacktrace 2
}

__log_stacktrace(){
	[[ "${__log__DEBUG:-}" != "yes" && "${__log__STACKTRACE:-}" != "yes" ]] || {
		local I="${1:-1}" BEGIN="${1:-1}";
		for (( I=BEGIN; I<${#FUNCNAME[@]}; I++ )); do
				echo $'\t\t'"at ${FUNCNAME[$I]}(${BASH_SOURCE[$I]}:${BASH_LINENO[$I-1]})" >&2
		done; echo '';
	}
}
function __log_trim() {
  local VAL="$1";
  VAL="${VAL#"${VAL%%[![:space:]]*}"}";
  VAL="${VAL%"${VAL##*[![:space:]]}"}";
  printf "$VAL";
}

function __log_enable_debug_mode  { __log__DEBUG="yes"; }
__log_disable_debug_mode(){ __log__DEBUG="no"; }
function __log_enable_stacktrace  { __log__STACKTRACE="yes"; }
__log_disable_stacktrace(){ __log__STACKTRACE="no";  }



alias fatal='log::fatal'
alias error='log::error'
alias warn='log::warn'
alias info='log::info'
alias debug='log::debug'
alias panic='log::panic'
alias unimplemented='log::unimplemented'
alias todo='log::todo'