#!/usr/bin/env bash


if ! command -v conda &> /dev/null; then
  echo " conda could not be found, installing..."

  curl -L "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o install_miniconda.sh
  ./install_miniconda.sh -b
  rm ./install_miniconda.sh
fi
