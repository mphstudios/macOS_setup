#!/bin/sh

function add_shell {
  local shell_path = "$(command -v $1)"
  local as_default = $2 || false

  if [ ! fgrep -q "$shell_path" /etc/shells ]; then
    message "Adding '$shell_path' to /etc/shells"
    sudo zsh -c 'echo /usr/local/bin/bash >> /etc/shells'
  fi

  if as_default; then sudo chsh -s "$shell_path" "$USER"
}

# Install Homebrew version of GNU Bourne Again SHell
function install_bash {
  install_homebrew_package 'bash'
  install_homebrew_package 'bash-completion@2'
  add_shell 'bash'
}

# Install Color LS to colorize the `ls` output
# See https://github.com/athityakumar/colorls
function install_colorls {
  message "Installing colorls ruby gem..."
  gem install colorls
  message "Adding colorls completions to shell profiles"
  local completions = "$(dirname $(gem which colorls))/tab_complete.sh"
  if [ -f $HOME/.bashrc ]; then echo "source $(completions)" >> $HOME/.bashrc
  if [ -f $HOME/.zshrc ]; then echo "source $(completions)" >> $HOME/.zshrc
}

# Install Homebrew version of Z shell as the default shell
function install_zshell {
  install_homebrew_package 'zsh'
  install_homebrew_package 'zsh-autosuggestions'
  install_homebrew_package 'zsh-completions'
  install_homebrew_package 'zplug'
  add_shell 'zsh' 'default'
}

# Install zsdoc to default path-prefix /usr/local
# @see https://github.com/z-shell/zsdoc
function install_zsdoc {
  git clone https://github.com/z-shell/zsdoc $HOME/Code/zsdoc
  cd zsdoc
  make
  sudo make install
  ln -s $(which zsd) "$(dirname $(which zsd))/zsdoc"
}

function install_shells {
  install_zshell
  install_bash
  install_colorls
}

export -f install_shells
