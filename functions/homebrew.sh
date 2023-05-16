#!/bin/sh

# Install packages from brewfiles
# @see https://docs.brew.sh/Manpage#bundle-subcommand
function install_homebrew_bundles {
  install_bundle 'brewfiles/base'
  confirm "Install cask applications?" "Y" && install_bundle 'brewfiles/casks' || skip "cask applications"
  confirm "Install cask fonts?" "Y" && install_bundle 'brewfiles/fonts' || skip "cask fonts"
  confirm "Install from App Store?" "Y" && install_bundle 'brewfiles/mas' || skip "Mac App Store applications"
}

# Install a package using Homebrew
# 
# @param {String} package  Homebrew package name to install
function install_homebrew_package {
  local package=$1

  if [[ -z $package ]]; then
    message "package is a required argument"
    return 0
  fi

  command -v brew >& /dev/null || install_homebrew

  if brew ls --versions "$package" >& /dev/null
  then
    message "\xE2\x9C\x94 $package"
  else
    brew install "$package" 2>&1
  fi
}

# Install packages in a Homebrew brewfile
# @see https://docs.brew.sh/Manpage#bundle-subcommand
# 
# @param {String} brewfile  Path to a brewfile
function install_bundle {
  local brewfile=$1

  if [[ -z $brewfile ]]; then
    echo "brewfile is a required argument"
    return 0
  fi

  # Ensure that node and npm install properly via Homebrew
  unset -v NODE_PATH

  command -v brew >& /dev/null || install_homebrew

  message "Installing Homebrew packages from $brewfile"
  brew bundle --file="$brewfile"

  message "Removing cached Homebrew downloads…"
  brew cleanup
}

# Install Homebrew package manager
# @see https://docs.brew.sh/Installation
function install_homebrew {
  if ! command -v brew >& /dev/null
  then
    message "Installing Homebrew package manager…"
    /bin/bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set Homebrew environment variables and add brew command to PATH
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.profile

    echo 'export HOMEBREW_CASK_OPTS="--appdir=/Applications --require-sha"' >> ~/.profile
    echo 'export HOMEBREW_COLOR=1' >> ~/.profile

    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Disable analytics @see docs.brew.sh/Analytics
    brew analytics off
  fi
}
