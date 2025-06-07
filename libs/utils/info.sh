#! /usr/bin/env bash


info::os-arch() {
    printf "$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)"
}
info::os-type() {
    printf "$(uname | awk '{print tolower($0)}')"
}
info::os-release() {
    printf "$(cat /etc/*release | grep ^NAME | sed 's/NAME="//' | sed 's/"//')"
}
info::os-name() {
    printf "$(awk -F "=" '/^NAME/ {print $2}' /etc/*-release |  tr -d '"')"
}