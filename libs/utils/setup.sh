#!/usr/bin/env bash

# --- load with ----------------------------------------------------------------------
# NAME="setup.sh";
# ID="270b6424115703723e1af3a727c010a3";
# REV="4ed1fa4386c311951cab03a17a38054476cf75f3";
# REV="7e76b6cccb95543b39be6a0315c0a3a06b527b1c";

# eval "$(curl -s -o- https://gist.githubusercontent.com/JeanMGirard/$ID/raw/$REV/$NAME)";
# -------------------------------------------------------------------------------------

INSTALLED_PACKAGES=""

touch ~/.bashrc ~/.zshrc ~/.profile ~/.zprofile


log_install(){
	echo "Installing: $1" && sleep 1;
}
log_installed(){
	installed_add "$1"
	echo " \"$1\" installed";
}
log_skipped(){
	installed_add "$1"
	echo " \"$1\" already installed";
}

cmd_wrap(){
	TEST="" PKG="" CMD=""

  while [[ $# -gt 0 ]]; do case "$1" in
    -t | --test) TEST="$2"; shift; ;;
   	*) if [[ -z "$PKG" ]]; then PKG="$1"; else CMD="$CMD $1"; fi
  esac; shift; done;

  if [[ "$(setup::installed --test "${TEST:-$PKG}" $PKG)" == "no" ]]; then
  	# echo "setup::installed --test \"${TEST:-$PKG}\" $PKG"
  	log_install $PKG;
  	eval "$CMD $PKG"
  	log_installed $PKG
  else
    log_skipped $PKG;
  fi
}
cmd_install() {
	MGR="$(setup::package-mgr)"
	case "$MGR" in
		apt | apt-get | yum | zypper | dnf) echo "$MGR install -y"; ;;
		pacman) echo "$MGR -Syu"; ;;
		apk | *) echo "$MGR install"; ;; #  || echo "echo 'Unknown package manager: $MGR'";
	esac
}
cmd_update() {
		MGR="$(setup::package-mgr)"

  	case "$MGR" in
  		apt | apt-get | yum) echo "$MGR update"; ;;
  		*) echo "$MGR update"; ;; #  echo "echo 'Unknown package manager: $MGR'";
  	esac
}
cmd_upgrade() {
  		MGR="$(setup::package-mgr)"

    	case "$MGR" in
    		apt | apt-get | yum) echo "$MGR upgrade -y"; ;;
    		*) echo "$MGR upgrade"; ;; #  echo "echo 'Unknown package manager: $MGR'";
    	esac
}

setup::register-alias(){
  touch ~/.aliases
  LN="alias $1=";
  alias $1="$2";
  sed -i "/^$LN/d" ~/.aliases;
  echo "$LN'$2'" >> ~/.aliases;
}
setup::register-repo(){
  unset CONTINUE CAN_FAIL NAME URL REPO_TYPE

  while test $# -gt 0; do
    case "$1" in
      -y | --yes) CONTINUE="yes" ;;
      -t | --try) CAN_FAIL="on" ;;
      -* | --*)   echo "bad option $1" ;;
      *)
        if   [[ -z "$NAME" ]];  then NAME="$1";
        elif [[ -z "$URL" ]];   then URL="$1";
        elif [[ -z "$REPO_TYPE" ]]; then
          REPO_TYPE="$NAME"
          NAME="$URL";
          URL="$1";
        else
          echo "too many arguments $1";
          return;
        fi
        ;;
    esac;
    shift;
  done

  if [[ -z "$URL" ]]; then
    echo "missing values";
    return;
  elif [[ -z "$REPO_TYPE" ]]; then
    if   [[ "$URL" == *"apt"* ]]; then REPO_TYPE="apt";
    elif [[ "$URL" == *"yum"* ]]; then REPO_TYPE="yum";
    elif command -v apt &> /dev/null;   then REPO_TYPE="apt";
    elif command -v yum &> /dev/null;   then REPO_TYPE="yum";
    fi
  fi


  if [[ -z "$REPO_TYPE" ]]; then
    echo "unable to resolve the repo type"
    return;
  fi


  if [[ "$REPO_TYPE" == "apt" ]]; then
    if ! command -v apt &> /dev/null; then
      return;
    fi;
    CONTENT="deb [trusted=yes] $URL /"
    TO_FILE="/etc/apt/sources.list.d/$NAME.list"
    EXTRA_CMD="sudo apt update"

  elif [[ "$REPO_TYPE" == "yum" ]]; then
    if ! command -v yum &> /dev/null; then
      return;
    fi;
    CONTENT=$"[$NAME]\nname=$NAME Repo\nbaseurl=$URL\nenabled=1\ngpgcheck=0"
    TO_FILE="/etc/yum.repos.d/$NAME.repo"
  fi



  if [[ "$CONTINUE" != "yes" ]]; then
    echo -e "\nwill write to '$TO_FILE'\n----- ";
    echo -e "$CONTENT\n-----\n";
    return;
  fi

  echo -e "$CONTENT" | sudo tee "$TO_FILE"
  $EXTRA_CMD
}

installed_clear() {
	INSTALLED_PACKAGES=""
}
installed_list(){
	echo "$INSTALLED_PACKAGES" | sed 's/:/ /g'
}
installed_add(){
  if [[ "$INSTALLED_PACKAGES" != *":$1:"* ]]; then
    INSTALLED_PACKAGES="$INSTALLED_PACKAGES:$1:";
  fi;
}

install_repo(){
	if [[ "$(setup::installed $@)" == "no" ]]; then
		log_install $@;
		sudo `cmd_install` "$1";
		log_installed $@;
	else
		log_skipped $@;
	fi
}
install_pip(){
	cmd_wrap $@ "sudo -H pip install";
}
install_npm(){
	cmd_wrap $@ "npm i -g";
}
install_go(){
	cmd_wrap $@ "go install";
}
install_rust(){
	cmd_wrap $@ "cargo install -f";
}

setup::package-mgr() {
  if   command -v apt-get &> /dev/null; then echo "apt-get"
  elif command -v yum &> /dev/null; then echo "yum"
  elif command -v apk &> /dev/null; then echo "apk"
  elif command -v zypper &> /dev/null; then echo "zypper"
  elif command -v pacman &> /dev/null; then echo "pacman"
  elif command -v dnf &> /dev/null; then echo "dnf"
  fi
}
setup::installed(){
	TEST=; CMD="";
	while [[ $# -gt 0 ]]; do case "$1" in
  	-t | --test) TEST="$2"; shift; ;;
 		*) CMD="$1";
  esac; shift; done;


	if ! command -v ${TEST:-$CMD} &> /dev/null; then
		printf "no";
  else
  	printf "yes";
  fi
}
setup::install(){
	local TEST="" PKG="" EVAL="" MGR="";

  while [[ $# -gt 0 ]]; do case "$1" in
    -t | --test) TEST="$2"; shift; ;;
  	--rust) MGR="rust"; ;;
  	--npm | --node) MGR="npm"; ;;
  	--pip | python) MGR="pip"; ;;
  	--go) MGR="go"; ;;
   	*) 	if [[ -z "$PKG" ]]; then PKG="$1"; else EVAL="$EVAL $1"; fi; ;;
  esac; shift; done;

  if ! command -v "${TEST:-$PKG}" &> /dev/null; then
  	log_install "$PKG";

		if [[ -z "$EVAL" ]]; then
			case "$MGR" in
				rust) install_rust "$EVAL"; ;;
    		npm) install_npm "$EVAL"; ;;
    		pip) install_pip "$EVAL"; ;;
    		go) install_go "$EVAL"; ;;
    		*) install_repo "$EVAL"; ;;
			esac;
    else
      # echo -e " TEST: $TEST \n PKG: $PKG \n EVAL: $EVAL $@"

    	if [[ "$EVAL" == "/"* ]]; then source $EVAL;
    	else eval "$EVAL"; fi;
		fi
    log_installed "$PKG";
  else
  	log_skipped "$PKG";
  fi;
}
setup::install-many(){
  # echo "Installing packages: $@" && sleep 2;
  for pkg in $@; do setup::install "$pkg"; done;
}

