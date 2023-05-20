#!/bin/sh

# Setup script for a development machine running macOS
set -Ee -o pipefail

COMPUTER=${1:-$(scutil --get ComputerName)}
REPOSITORY='https://raw.githubusercontent.com/mphstudios/macOS_setup/main'
SRC_DIR=$(cd $(dirname $0); pwd)
STARTTIME=$(date +%s)

# Abort script if not run on macOS
if [[ $(uname -s) != "Darwin" ]]
then
  echo "This script can only be run on macOS."
  exit 1
fi

# if [ ! -f "$SRC_DIR/functions" ]
# then
#   echo "Downloading setup functions…"
#   for f in $(curl --fail --show-error --silent $REPOSITORY/functions)
#     curl --fail --remote-name --show-error --silent $REPOSITORY/functions/$f
#   done
# fi

source functions/asdf.sh
source functions/confirm.sh
source functions/defaults.sh
source functions/dotfiles.sh
source functions/git.sh
source functions/homebrew.sh
source functions/message.sh
source functions/notifiers.sh
source functions/shells.sh
source functions/ssh_keys.sh
source functions/xcode.sh

# Prompt for computer name
read -p "Enter computer name [$COMPUTER]: " response
if [[ $response ]]; then
  COMPUTER="$response"
  sudo scutil --set ComputerName "$COMPUTER"
fi

message "Setting up $COMPUTER"

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
    message "Installing Rosetta 2…"
    softwareupdate --install-rosetta --agree-to-license
  else
    message "\xE2\x9C\x94 Rosetta 2"
  fi
fi

install_xcode

install_homebrew_bundles

install_shells

install_asdf

if confirm "Install dotfiles?" "Y"
then
  install_dotfiles
  touch $HOME/.private
else
  echo "Skipped"
fi

confirm "Install update notifiers?" "Y" && install_notifiers

confirm "Configure git?" "Y" && configure_git

confirm "Generate SSH keys?" "Y" && generate_ssh_keys

confirm "Write system defaults?" "N" && write_defaults

ENDTIME=$(date +%s)

message "Setup of $COMPUTER completed.\n
  Elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
read -p "Would you like to restart the system now? [yN]" response
if [[ $response =~ ^([Yy]|yes)$ ]]; then
  shutdown -r now "Restarting $COMPUTER"
else
  message "Salut!"
  exit
fi
