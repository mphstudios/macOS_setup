#!/bin/sh

# Install packages from brewfiles
function install_homebrew_bundles {
  install_bundle 'brewfiles/base'
  prompt "Install cask applications?" "Y" && install_bundle 'brewfiles/casks'
  prompt "Install cask fonts?" "Y" && install_bundle 'brewfiles/fonts'
  prompt "Install from App Store?" "Y" && install_bundle 'brewfiles/mas'
}

# Install a package if it is not already installed
function install_homebrew_package {
  local package=$1

  test ! $(which brew) && install_homebrew

  if ! command package || ! brew ls --versions package > /dev/null;
  then
    brew install package
  else
    message "\xE2\x9C\x94 $package is installed in PATH"
  fi
}

function install_bundle {
  local brewfile=$1

  test ! $(which brew) && install_homebrew

  message "Installing Homebrew packages from $brewfile"

  download brewfile

  # ensure that node and npm install properly via Homebrew
  unset -v NODE_PATH

  brew bundle --file=$brewfile --require-sha

  message "Removing cached Homebrew downloads\u2026"
  brew cleanup
}

function install_homebrew {
  if test ! $(which brew); then
    message "Installing Homebrew package manager…"
    /usr/bin/ruby -e "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}
