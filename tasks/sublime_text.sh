#!/bin/sh

function symlink_sublime_settings {
  local dropbox_dir="$HOME/Dropbox/Application\ Support/"
  local settings_dir="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
  [ ! -L "$settings_dir" ] && rm -rf settings_dir
  ln -sfn dropbox_dir/Sublime\ Text/User settings_dir
}
