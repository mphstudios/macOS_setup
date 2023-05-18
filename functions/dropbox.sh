#!/bin/sh

function symlink_to_dropbox {
  prompt "Symlink ssh config to Dropbox?" "N" && {
    message "Symlinking ssh config to Dropbox"
    mkdir -p $HOME/.ssh
    if [ -f "~/.ssh/config" ]; then
      mv ~/.ssh/config ~/.ssh/config_old
    fi
    ln -fs ~/Dropbox/dotfiles/.ssh-config ~/.ssh/config
  }

  message "Starting ssh-agent in the background"
  eval "$(ssh-agent -s)"

  prompt "Symlink Sublime Text settings to Dropbox?" "N" && {
    message "Symlinking Sublime Text settings to Dropbox"
    DROPBOX_DIR="$HOME/Dropbox/Application\ Support/"
    SETTINGS_DIR="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
    if [[ ! -L "$SETTINGS_DIR" ]]; then
      rm -rf SETTINGS_DIR
    fi
    ln -sfn DROPBOX_DIR/Sublime\ Text/User SETTINGS_DIR
  }

  prompt "Symlink Sketch app plugins and templates to Dropbox?" "N" && {
    message "Symlinking Sketch app plugins and templates to Dropbox"
    DROPBOX_DIR="$HOME/Dropbox/Application\ Support/"
    SETTINGS_DIR="$HOME/Library/Application Support/com.bohemiancoding.sketch3"
    if [[ ! -L "$SKETCH_SETTINGS" ]]; then
      rm -rf SKETCH_SETTINGS
    fi
    ln -sfn DROPBOX_DIR/Sketch/Libraries SETTINGS_DIR
    ln -sfn DROPBOX_DIR/Sketch/Plugins SETTINGS_DIR
    ln -sfn DROPBOX_DIR/Sketch/Templates SETTINGS_DIR
  }
}
