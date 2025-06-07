#!/bin/sh

PACKAGES='openssl curl gnupg git tar unzip'
PACKAGES_DEV="dos2unix nano bash-completion"

PROFILE=$HOME/.profile
BASH_PROFILE=$HOME/.bash_profile
ZSH_PROFILE=$HOME/.zprofile

if [ ! -f $PROFILE ]; then touch $PROFILE ; fi
if [ ! -f $BASH_PROFILE ]; then touch $BASH_PROFILE ; fi
if [ ! -f $ZSH_PROFILE ]; then touch $ZSH_PROFILE ; fi
chmod a+x $PROFILE $BASH_PROFILE $ZSH_PROFILE


OS_RELEASE="$(cat /etc/*release | grep ^NAME | sed 's/NAME="//' | sed 's/"//')"
OS_NAME=$(awk -F "=" '/^NAME/ {print $2}' /etc/*-release |  tr -d '"')



echo "
export OS_RELEASE='$OS_RELEASE'
export OS_NAME='$OS_NAME'
" >> $PROFILE

echo 'if [ -f ~/.profile ]; then . ~/.profile; fi' >> $BASH_PROFILE
echo 'if [ -f ~/.profile ]; then . ~/.profile; fi' >> $ZSH_PROFILE



if command -v apt-get &> /dev/null; then
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y `echo $PACKAGES` `echo $PACKAGES_DEV`
elif command -v yum &> /dev/null; then
  sudo yum update
  sudo yum upgrade -y
  sudo yum install -y `echo $PACKAGES` `echo $PACKAGES_DEV`
elif command -v zypper &> /dev/null; then
  sudo zypper refresh
  sudo zypper update -y
  sudo zypper install -y `echo $PACKAGES` `echo $PACKAGES_DEV`
elif command -v pacman &> /dev/null; then
  sudo pacman -Syu `echo $PACKAGES` `echo $PACKAGES_DEV`
elif command -v dnf &> /dev/null; then
  sudo dnf upgrade -y
  sudo dnf install -y `echo $PACKAGES` `echo $PACKAGES_DEV`
fi
