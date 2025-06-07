

NODE_VERSION="16.15.1"

# ===================================================================
# node
if ! command -v node &> /dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"

  echo -e '#! /usr/bin/env bash\n' > ~/.profile.d/mod.nvm
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile.d/mod.nvm
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/mod.nvm

  nvm install "${NODE_VERSION:-16.15.1}"
  nvm use "${NODE_VERSION:-16.15.1}"
  nvm alias default "${NODE_VERSION:-16.15.1}"
fi
echo " 'nvm' Installed "
echo " 'node' Installed "