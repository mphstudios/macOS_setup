#!/bin/sh

function install_xcode {
  if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}"
  then
    message "\xE2\x9C\x94 Xcode Command Line Tools"
  else
    message "Installing Xcode Command Line Tools…"
    xcode-select --install
  fi
}
