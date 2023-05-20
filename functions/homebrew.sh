#!/bin/sh

# Install packages from brewfiles
function install_homebrew_bundles {
  install_bundle 'brewfiles/base'
  confirm "Install cask applications?" "Y" && install_bundle 'brewfiles/casks' || echo "Skipped"
  confirm "Install cask fonts?" "Y" && install_bundle 'brewfiles/fonts' || echo "Skipped"
  confirm "Install from App Store?" "Y" && install_bundle 'brewfiles/mas' || echo "Skipped"
}

function install_homebrew_package {
  local package=$1

  if [[ -z $package ]]; then
    echo "package argument is required"
    return 0
  fi

  command -v brew >& /dev/null || install_homebrew

  if brew ls --versions "$package" >& /dev/null
  then
    message "\xE2\x9C\x94 $package is installed in PATH"
  else
    brew install "$package" 2>&1
  fi
}

function install_bundle {
  local brewfile=$1

  if [[ -z $brewfile ]]; then
    echo "brewfile argument is required"
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

function install_homebrew {
  if ! command -v brew >& /dev/null
  then
    message "Installing Homebrew package manager…"
    /bin/bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set Homebrew environment variables and add brew command to PATH
    echo "$(/opt/homebrew/bin/brew shellenv)" >> ~/.bash_profile
    echo "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    export HOMEBREW_CASK_OPTS="--require-sha"
    export HOMEBREW_COLOR=1

    # Disable analytics @see docs.brew.sh/Analytics
    brew analytics off
  fi
}
