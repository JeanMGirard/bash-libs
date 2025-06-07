#! /usr/bin/env bash


git::push-mr(){
    eval $(git::env);
    git push --set-upstream origin $GIT_BRANCH \
    -o merge_request.create=true \
    -o merge_request.remove_source_branch=true \
    -o merge_request.title="$1" \
    -o merge_request.draft
}

git::env(){
    cat <<- EOF
    GIT_BRANCH="$(git branch | cut -d ' ' -f2)";
    GIT_ORIGIN="$(git remote get-url origin)";
    GIT_PROVIDER="$(git remote get-url origin | sed -E 's/^(git@|https:\/\/)//' | sed -E 's/:.*.git$//' | sed -E 's/\/{1}.+$//')";
    GIT_PATH="$(git remote get-url origin | sed -E 's/^(git@|https:\/\/)(\w|\.)+(.){1}//' | sed -E 's/\.git$//')";
    GIT_ORG="$(echo $GIT_PATH | sed -E 's/\/.*$//')"
    GIT_PROJECT="$(echo $GIT_PATH | sed -E 's/^(\w|\.)+\///')"
EOF
}