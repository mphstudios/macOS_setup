#!/bin/sh

# Setup script for a development machine running macOS
set -Eeu -o pipefail

source functions/asdf.sh
source functions/defaults.sh
source functions/download.sh
source functions/dropbox.sh
source functions/git.sh
source functions/homebrew.sh
source functions/message.sh
source functions/notifiers.sh
source functions/shells.sh
source functions/xcode.sh

COMPUTER=$1
REPOSITORY='https://raw.githubusercontent.com/mphstudios/macOS_setup/main'
SRC_DIR=$(cd "$(dirname "$0")"; pwd)
STARTTIME=$(date +%s)

# Abort script if not run on macOS
if [ "$(uname -s)" != "Darwin" ];
then
  message "This script can only be run on macOS."
  exit 1
fi

# Prompt for an administrator password upfront
sudo -v

# Keep-alive: update the existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

install_xcode

homebrew_install_bundles

install_asdf

install_shells

message "Creating .private file"
touch $HOME/.private

read -r -p "Install package update notifiers? [Yn]"
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
  install_notifiers
fi

# Configure git
read -r -p "Configure git now? [yN]" response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
  configure_git
fi

ln -fs /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

symlink_to_dropbox

read -r -p "Write system defaults? [yN]"
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
  write_defaults
fi

ENDTIME=$(date +%s)

message "Setup of $HOSTNAME completed.\n
  elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
read -r -p "Would you like to restart the system now? [yN]" response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
  shutdown -r now "Restarting $HOSTNAME" ;
else
  message "Salut!"; exit;
fi
