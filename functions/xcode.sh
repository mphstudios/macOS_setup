#!/bin/sh

function install_command_line_tools {
  local xpath=$(type xcode-select >& /dev/null && xcode-select --print-path)
  if test -d "${xpath}" && test -x "${xpath}"
  then
    message "$CHECK_MARK Xcode Command Line Tools"
  else
    message "Installing Xcode Command Line Tools…"
    xcode-select --install
  fi

  sudo xcodebuild -license accept
}
