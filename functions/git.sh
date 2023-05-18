#!/bin/sh

function configure_git {
  install_homebrew_package git
  install_homebrew_package git-lfs

  read -p "git username:" username
  git config --global user.name $username

  read -p "git email:" email
  git config --global user.email $email
}
