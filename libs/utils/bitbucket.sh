#!/usr/bin/env bash
# shellcheck disable=SC2068
# shellcheck disable=SC2094

BITBUCKET_URL=${BITBUCKET_URL:-"https://git.bnc.ca"}

#  export BITBUCKET_AUTH="Z2lyajAwNjpNREV5TkRNeE5EUTJOVE15T3RVUjJMV1hGS3pEV2lOTWdCdUNUZEVUbkdpbgo="
# source /Users/jeanmichel.girard@bnc.ca/Projects/JeanMGirard/Tools/bitbucket-tools/config.sh

bitbucket::auth(){
	local SAVE_AUTH=0 FIX_AUTH=0 SILENT=0 TEST_AUTH=0 username='' token='';

	while [[ $# -gt 0 ]]; do case "$1" in
	  --silent) SILENT=1; ;;
		-s | --save) SAVE_AUTH=1; ;;
		-r | --reset) unset BITBUCKET_AUTH; ;;
		-t | --test) TEST_AUTH=1; ;;
		--fix) unset BITBUCKET_AUTH; FIX_AUTH=1; ;;
    *) if [[ -z "$username" ]]; then username="$1"; else token="$1"; fi; ;;
	esac; shift; done;

	if [[ -z "$BITBUCKET_AUTH" ]]; then
		[[ -z "$username" ]] && {
			echo "Enter username:"
			read -r username
		}
		[[ -z "$token" ]] && {
			echo "Enter auth token or password:"
			read -r token
		}

		[ -z "$username" ] || [ -z "$token" ] && {
			echo "Username or token is empty. Aborting."
			return
		}
		# shellcheck disable=SC2155
		export BITBUCKET_AUTH="$(echo "$username:$token" | base64)"

		[ $SILENT -eq 0 ] && echo "Updated environment variable BITBUCKET_AUTH."
	else
		[ $SILENT -eq 0 ] && echo "Environment variable BITBUCKET_AUTH already set. use --fix or --reset to unset it."
	fi

	[ $FIX_AUTH -gt 0 ] && open -a Safari "$BITBUCKET_URL"

	if [ $TEST_AUTH -gt 0 ]; then
  	url="${BITBUCKET_URL}/rest/api/latest/projects?start=0&limit=1"

		[ $SILENT -eq 0 ] && echo "Testing auth..."
		[ $SILENT -eq 0 ] && echo curl -X GET -s --url "$url" --header 'Accept: application/json' -u "$(echo $BITBUCKET_AUTH | base64 -d)"
		curl -X GET -s --url "$url" --header 'Accept: application/json' -u "$(echo $BITBUCKET_AUTH | base64 -d)" 1> /dev/null || {
			[ $SILENT -eq 0 ] && echo "Failed to authenticate. Aborting."
			return 1
		}
	fi

	if [[ -n "$BITBUCKET_AUTH" ]] && [ $SAVE_AUTH -gt 0 ]; then
		[ -f "$HOME/.profile" ] 		  && sed -i.bak '/^export BITBUCKET_AUTH=/d' "$HOME/.profile";
		[ -f "$HOME/.bash_profile" ] && sed -i.bak '/^export BITBUCKET_AUTH=/d' "$HOME/.bash_profile";
		[ -f "$HOME/.zprofile" ] 		&& sed -i.bak '/^export BITBUCKET_AUTH=/d' "$HOME/.zprofile";

		[ -f "$HOME/.profile" ] 			&& echo "export BITBUCKET_AUTH=$BITBUCKET_AUTH" >> "$HOME/.profile";
		[ -f "$HOME/.bash_profile" ] && echo "export BITBUCKET_AUTH=$BITBUCKET_AUTH" >> "$HOME/.bash_profile";
		[ -f "$HOME/.zprofile" ] 		&& echo "export BITBUCKET_AUTH=$BITBUCKET_AUTH" >> "$HOME/.zprofile";
		rm -f "$HOME/."*"profile.bak";

		[ $SILENT -eq 0 ] && echo "Saved environment variable BITBUCKET_AUTH in profile.";
	fi
}
bitbucket::dir_key(){
	echo -e "$(basename $(pwd))" | cut -d '_' -f1
}
bitbucket::projects(){
	bitbucket::auth --silent

  RESULTS='{ "isLastPage": false }'
  start=0
  limit=25
	jq_query=".values[]"

	while [[ $# -gt 0 ]]; do case "$1" in
		-q | --query) jq_query="$jq_query$2"; shift; ;;
	esac; shift; done;


  while [ "$(echo -E "$RESULTS" | jq -r '.isLastPage')" = "false" ]; do
  	url="${BITBUCKET_URL}/rest/api/latest/projects?start=$start&limit=$limit"

    RESULTS="$(curl -X GET -s --url "$url" --header 'Accept: application/json' -u "$(echo $BITBUCKET_AUTH | base64 -d)" )"
		echo -E "$RESULTS" | jq -rc "$jq_query" | while read -r line; do echo -E "$line"; done

    start=$(( start + limit ))
  done
}
bitbucket::keys(){
	bitbucket::projects -q '.key'
}
bitbucket::load-project(){
	bitbucket::auth --silent

	PROJECT="$(bitbucket::dir_key)"
	CLONE=0
	STRUCT=0
	ARGS=""
	doContinue=
	start=0
	limit=200


	while [[ $# -gt 0 ]]; do case "$1" in
		-s | --start) start=$2; shift; ;;
		-y | --yes) doContinue=y; ;;
		--preview) CLONE=1; ARGS="$ARGS --depth=1 --single-branch"; ;;
		--clone) CLONE=1; ;;
		--struct) STRUCT=1; ;;
		*) PROJECT="$1"
	esac; shift; done;

	echo "  $PROJECT"

	PROJECTS="$(curl -s --location -X GET "${BITBUCKET_URL}/rest/api/latest/projects/${PROJECT}/repos?start=$start&limit=$limit" \
		-u "$(echo $BITBUCKET_AUTH | base64 -d)" \
		--header 'Accept: application/json' \
		| jq -r '.values[] | { clone: .links.clone[], name: .slug } | select(.clone.name | contains("ssh")) | .clone.href + "|" + .name' \
		)"

	[ $CLONE -lt 1 ] && doContinue=y

	if [ "$doContinue" != "y" ]; then
		echo "$PROJECTS"
		echo -e "\n\n continue? [y/N]"
		read -r doContinue
	fi

	if [ "$doContinue" == "y" ]; then
		while IFS= read -r item; do
			repo_url="$(echo "$item" | cut -d '|' -f1)"
			repo_name="$(echo "$item" | cut -d '|' -f2)"

			[ -z "$repo_name" ] && continue

			if [ $CLONE -gt 0 ]; then
				[ -d "$repo_name" ] || git clone $ARGS "$repo_url" "$repo_name"
			elif [ $STRUCT -gt 0 ]; then
				echo "    $repo_name"
				mkdir -p "$repo_name"
			fi

		done <<< "$PROJECTS"
	fi;
}

bitbucket::mktree(){
	for k in $(bitbucket::keys); do
		mkdir -p "$k";
		cd "$k" || continue;
		bitbucket::load-project --struct;
		cd ../;
	done
}


export BITBUCKET_URL
