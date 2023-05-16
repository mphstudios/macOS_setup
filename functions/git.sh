#!/bin/sh

function configure_git {
  # homebrew_install git
  # homebrew_install git-lfs

  read -r -p "git username:" username
  git config --global user.name $username

  read -r -p "git email:" email
  git config --global user.email $email

  ssh-keygen -t rsa -b 4096 -C "$email" -f github_rsa

  ssh-add -K ~/.ssh/github_rsa

  read -r -p "Would you like to add this key to GitHub now? [yN]" response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
  then
    message "Copying github_rsa.pub to clipboard"
    open https://github.com/settings/keys
    read -r -p "Paste the key into GitHub and press any key to continue setup" response
    ssh -T git@github.com
  fi
}

export -f configure_git
