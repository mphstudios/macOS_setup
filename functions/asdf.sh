#!/bin/sh

function install_asdf {
  message "Installing asdf…"

  install_homebrew_package 'asdf'

  local rc_file=$HOME/.asdfrc

  if [ ! -f $rc_file ]; then
    message "creating $rc_file"
    echo "legacy_version_file = yes"  >> $rc_file
  fi

  message "installing plugins…"

  # GPG is required to verify plugins
  install_homebrew_package 'gpg'

  asdf plugin-add direnv https://github.com/asdf-community/asdf-direnv
  # Use Homebrew installed version of direnv
  asdf direnv setup --shell bash --version system
  asdf direnv setup --shell zsh --version system
  asdf global direnv system

  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs latest
  asdf global nodejs latest
  asdf reshim nodejs

  asdf plugin-add python https://github.com/asdf-community/asdf-python
  asdf install python latest
  asdf global python latest
  asdf reshim python

  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  asdf install ruby latest
  asdf global ruby latest

  local brew_prefix=$(brew --prefix asdf)

  # Install asdf for Bash
  message "adding asdf to bash"
  echo -e "\n\"$brew_prefix/libexec/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n\"$brew_prefix/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile

  # Install asdf for ZSH
  message "adding asdf to zsh"
  echo -e "\n$brew_prefix/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

  message "adding asdf aliases"
  (echo; echo "alias tools='$(command -v asdf)'") >> ~/.aliases
}
