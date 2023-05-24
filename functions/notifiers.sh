#!/bin/sh

function install_notifiers {
  message "Installing package update notifiers for Homebrew and NPM…"

  install_homebrew_package terminal-notifier

  sudo cp -fX $SRC_DIR/bin/*-notifier /usr/local/bin/

  # Set permissions on notifier scripts
  sudo chmod 755 /usr/local/bin/brew-updates-notifier
  sudo chmod 755 /usr/local/bin/npm-outdated-notifier

  if [ ! -d ~/Library/LaunchAgents ]
  then
    mkdir ~/Library/LaunchAgents
  fi

  sudo cp -fX $SRC_DIR/LaunchAgents/*.plist ~/Library/LaunchAgents/

  # User LaunchAgents must be readable by the user
  # and must NOT be writable by the group or other
  sudo chmod 644 ~/Library/LaunchAgents/*.plist

  message "adding alias 'notify' for terminal-notifier"
  local xpath=$(command -v terminal-notifier)
  echo -e "\n# Terminal-notifier\nalias notify='$xpath'" >> ~/.aliases
}
