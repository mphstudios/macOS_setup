#!/bin/sh

# Install packages from a Homebrew bundle file
function homebrew_install_bundles {
  install_bundle 'brewfiles/bundle'

  read -r -p "Install cask applications bundle? [Yn]"
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
  then
    install_bundle 'brewfiles/casks'
  fi

  read -r -p "Install cask fonts bundle? [Yn]"
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
  then
    install_bundle 'brewfiles/fonts'
  fi

  read -r -p "Install Mac App Store bundle? [Yn]"
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
  then
    install_bundle 'brewfiles/mas'
  fi
}

# Install a package if it is not already installed
function homebrew_install_package {
  local package=$1

  if test ! $(which brew); then
    install_homebrew
  fi

  # brew ls --versions $package || brew install $package

  if ! command package || ! brew ls --versions package > /dev/null;
  then
    message "Homebrew $package can not be found in PATH"
    read -r -p "Would you like to install $package now? [Yn]"
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
    then
      brew install package
    fi
  else
    message "Homebrew $package is already installed in PATH"
    read -r -p "Would you like to install $package now? [Yn]"
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
    then
      brew update package
    fi
  fi
}

function install_bundle {
  local bundle_file=$1

  if test ! $(which brew); then
    install_homebrew
  fi

  # ensure that node and npm install properly via Homebrew
  unset -v NODE_PATH

  message "Installing Homebrew packages from $bundle_file"

  brew update
  brew upgrade

  download bundle_file

  brew bundle --file=$SRC_DIR/$bundle_file --require-sha

  message "Removing cached Homebrew downloads..."
  brew cleanup
}

function install_homebrew {
  if test ! $(which brew); then
    message "Installing Homebrew package manager..."
    /usr/bin/ruby -e "$(curl --fail --location --show-error --silent https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

export -f homebrew_install_bundles
export -f homebrew_install_package
