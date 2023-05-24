#!/bin/sh

# See https://www.sublimetext.com/docs/
function install_subl_command {
  ln -fs /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
}

function symlink_sublime_settings {
  local dropbox_dir="$HOME/Dropbox/Application\ Support/"
  local settings_dir="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
  [ ! -L "$settings_dir" ] && rm -rf settings_dir
  ln -sfn dropbox_dir/Sublime\ Text/User settings_dir
}
