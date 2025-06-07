#! /usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
mkdir -p "$HOME/.config" "$HOME/.snippets" "$HOME/.snippets/include"


GITLAB_API="${GITLAB_API:-https://gitlab.com/api/v4}"
GITLAB_TOKEN="${GITLAB_TOKEN:-}"


PREV_GITLAB="";
# Temp
PROJECT_ID="36912095"



gitlab::cache-env(){ PREV_GITLAB="$(gitlab::env)"; eval "$PREV_GITLAB"; }
gitlab::reset-env(){ eval "$PREV_GITLAB"; unset PREV_GITLAB; }
gitlab::env(){
  cat <<-EOF
	GITLAB_API="${GITLAB_API:-https://gitlab.com/api/v4}"
	GITLAB_TOKEN="${GITLAB_TOKEN:-}"
	EOF
}



gitlab::get-snippets(){
	TOKEN="${GITLAB_TOKEN:-}"

    curl -Ls "$GITLAB_API/snippets" \
        --header "Private-Token: $GITLAB_TOKEN"
}
gitlab::get-snippet(){
    ID="";FILE="";RES="";
	TOKEN="${GITLAB_TOKEN:-}"
    EVAL=0;
    INTERACTIVE=${INTERACTIVE:-1};
    SILENT=${SILENT:-0};

    while [[ $# -gt 0 ]]; do case "$1" in
        --eval) EVAL=1; ;;
        --silent) SILENT=1; ;;
        --no-prompt) INTERACTIVE=0; ;;
        -s) SILENT=1; ;;
        -i) INTERACTIVE=1; ;;
        *)  if   [[ -z "$ID" ]];    then ID="$1";
            elif [[ -z "$FILE" ]];  then FILE="$1";
            fi;
    esac; shift; done;


    if [[ -z "$FILE" ]] && [[ $INTERACTIVE -gt 0 ]]; then
        echo "$(curl -Ls https://gitlab.com/api/v4/snippets/$ID --header "Private-Token: $GITLAB_TOKEN")" | jq -r '.files[].path';
        echo "Which file ? "; read FILE;
    fi

    if [[ -z "$FILE" ]]; then RES="$(curl -Ls "https://gitlab.com/api/v4/snippets/$ID" --header "Private-Token: $GITLAB_TOKEN" | jq .)";
    else RES="$(curl -Ls "https://gitlab.com/api/v4/snippets/$ID/files/main/$FILE/raw" --header "Private-Token: $GITLAB_TOKEN")";
    fi

	if [[ -z "$RES" ]]; then return; fi
    if [[ $EVAL -gt 0 ]];   then eval "$RES"; fi;
    if [[ $SILENT -eq 0 ]]; then echo "$RES"; fi;
}
gitlab::get-groups() {
	TOKEN="${GITLAB_TOKEN:-}";
    SEARCH="";

	while [[ $# -gt 0 ]]; do case "$1" in
        --token | -t) TOKEN="$2"; shift; ;;
        *)  if   [[ -z "$SEARCH" ]];  then SEARCH="$1"; fi;
    esac; shift; done;

    if [[ ! -z "$1" ]]; then SEARCH="search=$1"; fi

    curl -Ls "$GITLAB_API/groups?$SEARCH" \
        --header "Private-Token: $TOKEN" --header 'Content-Type: application/json'
}
gitlab::get-projects(){
    SEARCH="";ORDER_BY="last_activity_at";

	while [[ $# -gt 0 ]]; do case "$1" in
    	--token | -t) GITLAB_TOKEN="$2"; shift; ;;
    	--api) API="$2"; shift; ;;
        *)  if   [[ -z "$SEARCH" ]];  then SEARCH="$1"; fi;
    esac; shift; done;

    curl -Ls "$GITLAB_API/projects?search_namespaces=true&archived=false&sort=desc&order_by=$ORDER_BY&membership=true$SEARCH" \
        --header "Private-Token: $GITLAB_TOKEN" --header 'Content-Type: application/json'
}
gitlab::get-project(){
	TOKEN="${GITLAB_TOKEN:-}";

    if [[ ! -z "$1" ]]; then GIT_PROJECT="$1";
    elif [[ -z "$GIT_PROJECT" ]]; then eval $(git-env); fi

    if [[ -z "$PROJECT_ID" ]]; then
        gitlab_projects "${GIT_PROJECT}"
    else
        curl -Ls "$GITLAB_API/projects/${PROJECT_ID}" \
            --header "Private-Token: $GITLAB_TOKEN" --header 'Content-Type: application/json'
    fi
}


gitlab::update-mr(){
    PROJECT_ID="36912095"; MR_ID="45";
    URL="https://gitlab.com/api/v4//projects/${PROJECT_ID}/merge_requests/${MR_ID}"
    DATA="{
      \"title\": \"Title\",
      \"squash\": true, \"remove_source_branch\": true,
      \"reviewer_ids\": [1613331,9811635,11775772,11775780,11782770]
    }";
    curl $GITLAB_HEADERS -X PUT -L "$URL" --data-raw "$DATA";
}

gitlab::clone-tree(){
	PWD_1="$(pwd)"
	NAME=; OUTPUT=;
	TOKEN="${GITLAB_TOKEN:-}"
	DOMAIN='gitlab.com';

    while [[ $# -gt 0 ]]; do case "$1" in
        --out | --output | -o) OUTPUT="$2"; shift; ;;
        --domain) DOMAIN="$2"; shift; ;;
        --token | -t) TOKEN="$2"; shift; ;;
        *)  if   [[ -z "$NAME" ]];  then NAME="$1";
            fi;
    esac; shift; done;

	if 	[[ -z "$OUTPUT" ]]; then OUTPUT="."; else mkdir -p "$OUTPUT"; fi;
	if 	[[ ! -z "$NAME" ]]; then mkdir -p "$OUTPUT/$NAME"; 	fi

    for dirname in $(gitlab::get-groups $NAME | jq -r '.[].full_path'); do
        mkdir -p "$OUTPUT/$dirname"; # echo "$dirname";
    done


	cd "$OUTPUT"
    for dirname in ${NAME:-.}/*; do
		cd "$PWD_1"
		dirname="$(echo "$dirname" | sed 's/.\///g')"
        # echo $dirname
        for project in $(gitlab::get-projects "$dirname" | jq -r '.[].path_with_namespace'); do
            echo "$project ($DOMAIN:$project.git)";
            git clone git@$DOMAIN:$project.git "$OUTPUT/$project" --depth 0 --single-branch
        done;
    done;
	find "$PWD_1/$OUTPUT" -type d -empty -delete
}
