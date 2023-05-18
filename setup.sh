#!/bin/sh

# Setup script for a development machine running macOS
set -Eeu -o pipefail

source functions/asdf.sh
source functions/defaults.sh
source functions/dotfiles.sh
source functions/download.sh
source functions/git.sh
source functions/homebrew.sh
source functions/message.sh
source functions/notifiers.sh
source functions/prompt.sh
source functions/shells.sh
source functions/ssh_keys.sh
source functions/xcode.sh

COMPUTER=$1
REPOSITORY='https://raw.githubusercontent.com/mphstudios/macOS_setup/main'
SRC_DIR=$(cd "$(dirname "$0")"; pwd)
STARTTIME=$(date +%s)

# Abort script if not run on macOS
if [[ $(uname -s) != "Darwin" ]]
then
  message "This script can only be run on macOS."
  exit 1
fi

# When this setup script is invoked without arguments
if [ ! -n $COMPUTER ]; then
  # prompt user for computer name
  read -p "Computer Name (Return to leave computer name unchanged):" response
  if [[ $response ]]; then
    COMPUTER=$response;
  fi
fi

# Prompt for an administrator password upfront
sudo -v

# Keep-alive: update the existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check chip architecture
if [[ $(uname -m) == "arm64" ]]
then
  # Install Rosetta 2 is already installed
  if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto > /dev/null 2>&1
  then
    message "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
  else
    message "Rosetta 2 is installed."
  fi
fi

install_xcode

install_homebrew_bundles

install_shells

install_asdf

install_dotfiles

message "Creating .private file"
touch $HOME/.private

prompt "Install update notifiers?" "Y" && install_notifiers
prompt "Configure git?" "N" && configure_git
prompt "Generate SSH keys?" "Y" && generate_ssh_keys
prompt "Write system defaults?" "N" && write_defaults

ENDTIME=$(date +%s)

message "Setup of $HOSTNAME completed.\n
  elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
read -p "Would you like to restart the system now? [yN]" response
if [[ $response =~ ^([Yy]|yes)$ ]];
then
  shutdown -r now "Restarting $HOSTNAME" ;
else
  message "Salut!"; exit;
fi
