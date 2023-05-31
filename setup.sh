#!/bin/sh

# Setup script for a development machine running macOS
set -Ee -o pipefail

COMPUTER=${1:-$(scutil --get ComputerName)}
SRC_DIR=$(cd $(dirname $0); pwd)
STARTTIME=$(date +%s)

# Abort script if not run on macOS
if [[ $(uname -s) != "Darwin" ]]
then
  echo "This script can only be run on macOS."
  exit 1
fi

source functions/asdf.sh
source functions/confirm.sh
source functions/defaults.sh
source functions/dotfiles.sh
source functions/git.sh
source functions/homebrew.sh
source functions/notifiers.sh
source functions/output.sh
source functions/shells.sh
source functions/ssh_keys.sh
source functions/sublime_text.sh
source functions/xcode.sh

# Prompt for computer name
read -p "Enter computer name [$COMPUTER]: " response
if [[ $response ]]
then
  # Set computer name (as done via System Preferences > Sharing)
  COMPUTER="$response"
  sudo scutil --set ComputerName $COMPUTER
  sudo scutil --set HostName $COMPUTER
  sudo scutil --set LocalHostName $COMPUTER
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER
  dscacheutil -flushcache
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

install_command_line_tools

install_homebrew_bundles

install_shells

install_asdf

if confirm "Install dotfiles?" "Y"
then
  install_dotfiles
  message "Private environment variables, such as your NPM access token, should be set in ~/.private"
  touch $HOME/.private
  echo "export NPM_TOKEN=$token" >> $HOME/.private
else
  skip "installing dotfiles"
fi

confirm "Configure git?" "Y" && configure_git || skip "git configuration"

confirm "Install update notifiers?" "Y" && install_notifiers || skip "update notifiers"

confirm "Symlink Sublime Text settings to Dropbox?" "Y" && symlink_sublime_settings || skip "symnlinks to Dropbox"

confirm "Write system defaults?" "N" && write_defaults || skip "writing system defaults"

ENDTIME=$(date +%s)

message "Setup of $COMPUTER completed.\n
  Elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
if confirm "Would you like to restart the system now?" "N"
  shutdown -r now "Restarting $COMPUTER"
else
  message "Salut!" && exit
fi
