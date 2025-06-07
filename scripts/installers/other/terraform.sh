
TF_VERSION='1.2.3'
TG_VERSION='0.38.1'
TERRAFILE_VERSION='0.7'
TF_DOCS_VERSION='0.16.0'

echo -e "\n* Installing terraform tools... \n" && (

  cat <<-EOF | install-pkg tfenv
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  ln -s ~/.tfenv/bin/* $HOME/.local/bin/
	EOF

  cat <<-EOF | install-pkg tgenv
  git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
  ln -s ~/.tgenv/bin/* $HOME/.local/bin/
	EOF
	
	install-pkg terraform "tfenv install ${TF_VERSION:=1.2.3}"
  install-pkg terragrunt "tgenv install $TG_VERSION"
  install-pkg tfsec "go install github.com/aquasecurity/tfsec/cmd/tfsec@latest"
  install-pkg tflint "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"


  cat <<-EOF | install-pkg terrafile
  curl -L "https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION:-0.7}/terrafile_${TERRAFILE_VERSION:-0.7}_Linux_x86_64.tar.gz" | sudo tar xz -C $HOME/.local/bin/
  sudo chmod +x $HOME/.local/bin/terrafile
	EOF

  cat <<-EOF | install-pkg terraform-docs
  curl -L "https://github.com/terraform-docs/terraform-docs/releases/download/v${TF_DOCS_VERSION:-0.16.0}/terraform-docs-v${TF_DOCS_VERSION:-0.16.0}-$(uname)-amd64.tar.gz" | sudo tar xz -C $HOME/.local/bin/
  sudo chmod +x $HOME/.local/bin/terraform-docs
	EOF
)


cat << EOF > ~/.profile.d/mod.terraform
  export PATH=\$PATH:\$HOME/.tfenv/bin

  alias tg='terragrunt
  alias tf='terraform
  alias tfdocs='terraform-docs
EOF