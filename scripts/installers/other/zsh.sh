#!/usr/bin/env bash

function getInstallCmd() {
  if command -v apt-get &> /dev/null; then echo "apt-get install -y"
  elif command -v yum &> /dev/null; then echo "yum install -y"
  elif command -v zypper; &> /dev/null; then echo "zypper install -y"
  elif command -v pacman; &> /dev/null; then echo "pacman -Syu"
  fi
}

if ! command -v zsh &> /dev/null; then
  echo " zsh could not be found, installing..."
  sudo `getInstallCmd` zsh
  echo " done."

  echo " installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo " done."
fi
