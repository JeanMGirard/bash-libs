#! /usr/bin/env bash

mkdir -p ~/.profile.d ~/packages
set +x

GO_VERSION="1.18"
NODE_VERSION="16.15.1"
TF_VERSION='1.2.3'
TG_VERSION='0.38.1'
TERRAFILE_VERSION='0.7'
TF_DOCS_VERSION='0.16.0'



ID="JeanMGirard/270b6424115703723e1af3a727c010a3";
REV="4ed1fa4386c311951cab03a17a38054476cf75f3";
NAME="setup.sh";
eval "$(curl -s -o- https://gist.githubusercontent.com/$ID/raw/$REV/$NAME)";



echo -e "\n* Verifying requirements... \n"
setup::install-many \
	python3-pip curl openssl git unzip bash-completion net-tools \
	hub	gnupg pass keychain ssh-askpass \
	jq peco nano fzf


# WSL ONLY
setup::install xdg-utils

# Examples
# setup::install pkg1 <(echo 'echo "[cmd]"')
# setup::install pkg1 'echo "[cmd]"'
# setup::install pkg1 <(cat << EOF
# echo "[cmd]"
# EOF
# )


if command -v apt &> /dev/null; then sudo apt autoremove -y; fi
# echo '[ -d ~/.profile.d/ ] && for file in $(find ~/.profile.d/ -type f) ; do source "$file"; done' >> ~/.profile



# ===================================================================
setup::install task 'sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin'
# ===================================================================

# ===================================================================
echo -e "\n* Installing developer tools... \n" && (
  setup::install   jsonnet
  setup::install ytt "curl -s -L https://carvel.dev/install.sh | sudo K14SIO_INSTALL_BIN_DIR=/usr/local/bin bash"
  # setup::install pre-commit "pip_install pre-commit --upgrade"
  # setup::install hygen "npm_install hygen"
  # setup::install codemod "pip_install codemod --upgrade"
  # setup::install codemod "npm_install @codemod/cli"
  # setup::install codemod-cli "npm_install codemod-cli"


  # setup::install cheat 'sudo curl -s -o /usr/local/bin/cheat -L https://raw.githubusercontent.com/alexanderepstein/Bash-Snippets/master/cheat/cheat && sudo chmod +x /usr/local/bin/cheat'
  setup::install notes 'curl -Ls https://raw.githubusercontent.com/pimterry/notes/latest-release/install.sh | sudo bash'
  setup::install pet <(cat << EOF
    if command -v dpkg &> /dev/null; then
      curl -s -o /tmp/pet_0.3.6.deb -L https://github.com/knqyf263/pet/releases/download/v0.3.6/pet_0.3.6_linux_amd64.deb && \
        sudo dpkg -i /tmp/pet_0.3.6.deb && \
        rm /tmp/pet_0.3.6.deb
    elif command -v rpm &> /dev/null; then
      sudo rpm -ivh https://github.com/knqyf263/pet/releases/download/v0.3.0/pet_0.3.0_linux_amd64.rpm
    fi

    # .bashrc
    echo 'function pet-prev() {
      PREV=$(echo `history | tail -n2 | head -n1` | sed 's/[0-9]* //')
      sh -c "pet new `printf %q "$PREV"`"
    }' >> ~/.bashrc
    echo 'function pet-select() {
      BUFFER=$(pet search --query "$READLINE_LINE");
      READLINE_LINE=$BUFFER;
      READLINE_POINT=${#BUFFER};
    }' >> ~/.bashrc
    echo "bind -x '\"\C-x\C-r\": pet-select'" >> ~/.bashrc
    # .zshrc
    echo 'function pet-prev() {
      PREV=$(fc -lrn | head -n 1)
      sh -c "pet new `printf %q "$PREV"`"
    }' >> ~/.zshrc
    echo 'function pet-select() {
      BUFFER=$(pet search --query "$LBUFFER");
      CURSOR=$#BUFFER; zle redisplay;
    }' >> ~/.zshrc
    echo -e "zle -N pet-select;\nstty -ixon;\nbindkey '^s' pet-select;" >> ~/.zshrc
EOF
)
  setup::install snipkit <(cat << EOF
    setup::register-repo --try -y snipkit 'https://apt.fury.io/lemoony/';
    setup::register-repo --try -y snipkit 'https://yum.fury.io/lemoony/';
    setup::install snipkit
    #  writeToAliases "\n# [snippets]"
    register-Alias sn snipkip
EOF
)

#   [[ ! -d ~/packages/git-extra-commands ]] && setup::install git-extra-commands <(cat << EOF
#     git clone https://github.com/unixorn/git-extra-commands.git ~/packages/git-extra-commands
#     echo 'export PATH=$PATH:$HOME/packages/git-extra-commands/bin' > ~/.profile.d/mod.git-extra-commands
#     echo "alias git-extra-commands='ls -a \$HOME/packages/git-extra-commands/bin'" >> ~/.profile.d/mod.git-extra-commands
# EOF
# )

)
# echo -e "\n* Installing sysadmin tools... \n" && (
#   setup::install ergo 'curl -s https://raw.githubusercontent.com/cristianoliveira/ergo/master/install.sh | sh'
#   setup::install kubebox 'curl -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.10.0/kubebox-linux && chmod +x kubebox && sudo mv kubebox /usr/local/bin/'
# )
# echo -e "\n* Installing team collab tools... \n" && (
#   setup::install termchat "pip_install termchat --upgrade"
# )
echo -e "\n* Installing cloud tools... \n" && (
  setup::install aws  <(cat << EOF
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip ./aws
EOF
)
  setup::install eksctl "curl --silent --location \"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz\" | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin"
  setup::install aws-vault  <(cat << EOF
    sudo curl --silent -Lo /usr/local/bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v6.6.0/aws-vault-linux-amd64
    sudo chmod a+x /usr/local/bin/aws-vault
EOF
)
)

# ===================================================================
# Setup
echo -e "\n* Starting setup \n"
# pre-commit install
# pet configure
# snipkit config init
# snipkit manager add

echo -e "\n* installation completed \n"
