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

  asdf plugin add asdf-plugin-manager https://github.com/asdf-community/asdf-plugin-manager.git
  asdf plugin update asdf-plugin-manager v1.0.0
  asdf install asdf-plugin-manager 1.0.0
  asdf global asdf-plugin-manager 1.0.0

  # Add all plugins listed in ~/asdf/.plugin-versions
  asdf-plugin-manager add-all

  # asdf plugin-add direnv https://github.com/asdf-vm/asdf-direnv.git
  # asdf direnv setup --shell bash --version latest
  # asdf direnv setup --shell zsh --version latest

  # asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  # asdf install nodejs latest
  # asdf global nodejs latest
  # asdf reshim nodejs

  # asdf plugin-add python https://github.com/danhper/asdf-python.git
  # asdf install python latest:3
  # asdf global python latest:3
  # asdf reshim python

  # asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  # asdf install ruby latest

  local brew_prefix=$(brew --prefix asdf)

  # Install asdf for Bash
  message "adding asdf to bash"
  echo -e "\n\"$brew_prefix/libexec/asdf.sh\"" >> ~/.bash_profile
  echo -e "\n\"$brew_prefix/etc/bash_completion.d/asdf.bash\"" >> ~/.bash_profile

  # Install asdf for ZSH
  message "adding asdf to zsh"
  echo -e "\n$brew_prefix/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

  message "aliasing 'tools' to asdf"
  echo -e "\n# asdf\nalias tools='$(command -v asdf)'" >> ~/.aliases
}
