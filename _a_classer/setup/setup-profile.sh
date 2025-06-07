#!/bin/sh

sudo apt install -y bash-completion xdg-utils net-tools
echo "autoload -Uz compdef" >> ~/.zshrc

git clone git@gonebig.com:infra/devops-tools.git ~/.tks-devops-tools
~/.tks-devops-tools/install


export AWS_VAULT_BACKEND=file
export GPG_TTY="$( tty )"
echo '
export AWS_VAULT_BACKEND=file
export GPG_TTY="$( tty )"
' >> ~/.profile

echo "
alias awsv='aws-vault exec \${AWS_PROFILE:-default} -- aws'
alias aws-exec='aws-tools exec'
alias aws-scp='aws-tools scp'
alias aws-ssh='aws-tools ssh'
alias aws-tunnel='aws-tools tunnel'
" >> ~/.profile

echo 'source ~/.tks-devops-tools/shell-integration/bash/entry.sh' >> ~/.bash_profile
echo 'source ~/.tks-devops-tools/shell-integration/zsh/entry.zsh' >> ~/.zshrc


cat <<EOF
test
EOF
| sudo tee test.txt

tenant-cli profile create --stage dev
builddb-cli profile create
aws-vault add default

