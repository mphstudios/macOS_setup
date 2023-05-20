#!/bin/sh

# Install packages from brewfiles
function install_homebrew_bundles {
  install_bundle 'brewfiles/base'
  confirm "Install cask applications?" "Y" && install_bundle 'brewfiles/casks'
  confirm "Install cask fonts?" "Y" && install_bundle 'brewfiles/fonts'
  confirm "Install from App Store?" "Y" && install_bundle 'brewfiles/mas'
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

  # ensure that node and npm install properly via Homebrew
  unset -v NODE_PATH

  brew bundle --file=$brewfile

  message "Removing cached Homebrew downloads…"
  brew cleanup
}

function install_homebrew {
  if test ! $(which brew); then
    message "Installing Homebrew package manager…"
    /bin/bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Set Homebrew environment variables and add brew command to PATH
  echo "$(/opt/homebrew/bin/brew shellenv)" >> ~/.bash_profile
  echo "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

  export HOMEBREW_CASK_OPTS="--require-sha"
  export HOMEBREW_COLOR=1

  # Disable analytics @see docs.brew.sh/Analytics
  brew analytics off
}
