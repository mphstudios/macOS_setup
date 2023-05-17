#!/bin/sh

function symlink_to_dropbox {
  read -r -p "Symlink ssh config to Dropbox? [yN]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    message "Symlinking ssh config to Dropbox"
    mkdir -p $HOME/.ssh
    if [ -f "~/.ssh/config" ]; then
      mv ~/.ssh/config ~/.ssh/config_old
    fi
    ln -fs ~/Dropbox/dotfiles/.ssh-config ~/.ssh/config
  fi

  message "Starting ssh-agent in the background"
  eval "$(ssh-agent -s)"

  read -r -p "Symlink Sublime Text settings to Dropbox? [yN]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    message "Symlinking Sublime Text settings to Dropbox"
    DROPBOX_DIR="$HOME/Dropbox/Application\ Support/"
    SETTINGS_DIR="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
    if [[ ! -L "$SETTINGS_DIR" ]]; then
      rm -rf SETTINGS_DIR
    fi
    ln -sfn DROPBOX_DIR/Sublime\ Text/User SETTINGS_DIR
  fi

  message "Creating symlink for Sublime Text CLI tool"

  read -r -p "Symlink Sketch app plugins and templates to Dropbox? [yN]"
  if [[ $response =~ ^([Yy]|yes)$ ]];
  then
    message "Symlinking Sketch app plugins and templates to Dropbox"
    DROPBOX_DIR="$HOME/Dropbox/Application\ Support/"
    SETTINGS_DIR="$HOME/Library/Application Support/com.bohemiancoding.sketch3"
    if [[ ! -L "$SKETCH_SETTINGS" ]]; then
      rm -rf SKETCH_SETTINGS
    fi
    ln -sfn DROPBOX_DIR/Sketch/Libraries SETTINGS_DIR
    ln -sfn DROPBOX_DIR/Sketch/Plugins SETTINGS_DIR
    ln -sfn DROPBOX_DIR/Sketch/Templates SETTINGS_DIR
  fi
}

export -f symlink_to_dropbox
