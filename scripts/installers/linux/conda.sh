#!/usr/bin/env bash


if ! command -v conda &> /dev/null; then
  echo " conda could not be found, installing..."

  echo "NOT INSTALLED (conda)"
  exit 0

  if command -v apt-get &> /dev/null; then
    sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
  elif command -v yum &> /dev/null; then
    sudo yum install -y libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver
  elif command -v zypper; &> /dev/null; then
    sudo zypper install libXcomposite1 libXi6 libXext6 libXau6 libX11-6 libXrandr2 libXrender1 libXss1 libXtst6 libXdamage1 libXcursor1 libxcb1 libasound2  libX11-xcb1 Mesa-libGL1 Mesa-libEGL1
  elif command -v pacman; &> /dev/null; then
    sudo pacman -Sy libxau libxi libxss libxtst libxcursor libxcomposite libxdamage libxfixes libxrandr libxrender mesa-libgl  alsa-lib libglvnd
  fi


fi
