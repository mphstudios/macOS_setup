#!/bin/sh

function install_notifiers {
  message "Installing package update notifiers for Homebrew and NPM..."

  homebrew_install terminal-notifier

  cp -fX $SRC_DIR/bin/*-notifier /usr/local/bin/

  # Set permissions on notifier scripts
  chmod 755 /usr/local/bin/brew-updates-notifier
  chmod 755 /usr/local/bin/npm-outdated-notifier

  if [ ! -d ~/Library/LaunchAgents ]; then
    mkdir ~/Library/LaunchAgents
  fi

  cp -fX $SRC_DIR/LaunchAgents/*.plist ~/Library/LaunchAgents/

  # User LaunchAgents must be readable by the user
  # and must NOT be writable by the group or other
  chmod 644 ~/Library/LaunchAgents/*.plist

  message "adding alias 'notify' for terminal-notifier"
  echo -e "\n# Terminal-notifier\nalias notify='$(which terminal-notifier)'" >> ~/.aliases
}

export -f install_notifiers
