#!/bin/sh

# Install packages from brewfiles
function install_homebrew_bundles {
  # install packages from base bundle
  install_bundle 'brewfiles/base'

  read -r -p "Install cask applications bundle? [Yn]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    install_bundle 'brewfiles/casks'
  fi

  read -r -p "Install cask fonts bundle? [Yn]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    install_bundle 'brewfiles/fonts'
  fi

  read -r -p "Install Mac App Store bundle? [Yn]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    install_bundle 'brewfiles/mas'
  fi
}

# Install a package if it is not already installed
function install_homebrew_package {
  local package=$1

  if test ! $(which brew); then
    install_homebrew
  fi

  # brew ls --versions $package || brew install $package

  if ! command package || ! brew ls --versions package > /dev/null;
  then
    message "Homebrew $package can not be found in PATH"
    read -r -p "Would you like to install $package now? [Yn]"
    if [[ $response =~ ^([Yy]|yes)$ ]];
    then
      brew install package
    fi
  else
    message "Homebrew $package is already installed in PATH"
    read -r -p "Would you like to install $package now? [Yn]"
    if [[ $response =~ ^([Yy]|yes)$ ]];
    then
      brew update package
    fi
  fi
}

function install_bundle {
  local brewfile=$1

  if test ! $(which brew); then
    install_homebrew
  fi

  message "Installing Homebrew packages from $brewfile"

  download brewfile

  # ensure that node and npm install properly via Homebrew
  unset -v NODE_PATH

  brew bundle --file=$brewfile --require-sha

  message "Removing cached Homebrew downloads..."
  brew cleanup
}

function install_homebrew {
  if test ! $(which brew); then
    message "Installing Homebrew package manager..."
    /usr/bin/ruby -e "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

export -f install_homebrew_bundles
export -f install_homebrew_package
