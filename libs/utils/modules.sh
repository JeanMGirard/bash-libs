##! /usr/bin/env bash

TRUE=yes
FALSE=no



shell::ask_sudo() {
    sudo -v # Ask for the administrator password upfront
    # Update existing `sudo` time stamp until this script has finished
    # https://gist.github.com/cowboy/3118588
    while true; do
      sudo -n true; sleep 60;
      kill -0 "$$" || exit;
    done &> /dev/null &
}

shell::ask() {
	local TXT="$1";
	printf "$TXT ";
  read REPLY;
}

shell::ask_approval() {
	REPLY="$2";	local OPT="[y/N]";
	if echo "$REPLY" | grep -Eq '^[Yy](es|ES){0,1}$'; then OPT="[Y/n]"; fi;

  printf "$1 $OPT? "; read NEW_REPLY;
  if echo "$NEW_REPLY" | grep -Eq '^[yYnN]{1}(ES|es|O|o){0,1}$'; then	REPLY="${NEW_REPLY}";
  elif [[ ! -z "$NEW_REPLY" ]]; then printf "Invalid value '$NEW_REPLY'. Only accepts yes(y) & no(n).\n"
  fi;
}

shell::answered() {
  printf "$REPLY";
}
shell::answered_yes() {
	if echo "$REPLY" | grep -Eq '^[Yy]{1}.*'; then  printf "$TRUE";
  else printf "$FALSE"; fi
}


users::add_user(){
  local username="$1"
  local userhome="/mnt/h/${username}.wsl"

  useradd -m \
    -G sudo \
    -s /bin/bash \
    -d $userhome \
    $username

   chown -R $username $userhome
}
users::add_to_group(){
  local username="$1"
  local groupname="$2"

  usermod -aG $groupname $username
}



# echo "$(whoami)"
# [ "$UID" -eq 0 ] || exec sudo "$0" "$@"
# if [ "$EUID" -ne 0 ]; then echo "Please run as root"; exit; fi


