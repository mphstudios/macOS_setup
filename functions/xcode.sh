#!/bin/sh

function install_xcode {
  if [ type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
    test -d "${xpath}" && test -x "${xpath}" ]; then
    message "Xcode Command Line Tools is already installed."
  else
    message "Installing Xcode Command Line Tools..."
    xcode-select --install
  fi
}

export -f install_xcode
