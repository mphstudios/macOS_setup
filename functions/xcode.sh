#!/bin/sh

function install_xcode {
  local xpath=$(type xcode-select >& /dev/null && xcode-select --print-path)
  if test -d "${xpath}" && test -x "${xpath}"
  then
    message "\xE2\x9C\x94 Xcode Command Line Tools"
  else
    message "Installing Xcode Command Line Tools…"
    xcode-select --install
  fi
}
