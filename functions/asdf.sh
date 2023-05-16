#!/bin/sh

function install_asdf {
  message "Installing asdf..."

  homebrew_install_package asdf

  local rc_file = $HOME/.asdfrc

  if [ ! -f $rc_file ]; then
    message "creating $rc_file"
    echo "legacy_version_file = yes"  >> $rc_file
  fi

  message "installing plugins..."

  local plugins_dir = $(asdf root)/plugins

  # create the plugins directory if it does not exist
  mkdir -p $plugins_dir

  # GPG is required to verify plugins
  homebrew_install_package gpg

  asdf plugin-add direnv https://github.com/asdf-vm/asdf-direnv.git
  asdf install direnv latest
  asdf global direnv latest

  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs latest
  asdf reshim nodejs

  asdf plugin-add python https://github.com/danhper/asdf-python.git
  asdf install python latest:3
  asdf reshim python

  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  asdf install ruby latest

  # Install asdf for Bash
  message "adding asdf to bash..."
  echo -e "\n. \"$(brew --prefix asdf)/libexec/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile

  # Install asdf for ZSH
  message "adding asdf to zsh..."
  echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
}

export -f install_asdf
