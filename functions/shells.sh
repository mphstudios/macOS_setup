#!/bin/sh

function add_shell {
  local shell="$(command -v $1)"
  local default=${2:-false}

  if [[ -z $shell ]]
  then
    echo "shell is a required argument"
    return 0
  fi

  if [ ! grep -w "$shell" /etc/shells ]
  then
    message "Adding '$shell' to /etc/shells"
    sudo zsh -c 'echo /usr/local/bin/bash >> /etc/shells'
  fi

  [ "$default" = true ] && sudo chsh -s $shell $USER
}

# Install Bourne-Again SHell, UNIX command interpreter
function install_bash {
  install_homebrew_package 'bash'
  install_homebrew_package 'bash-completion@2'
  add_shell 'bash'
}

# Install Color LS to colorize the `ls` output
# See https://github.com/athityakumar/colorls
function install_colorls {
  message "Installing colorls ruby gem…"
  gem install colorls
  message "adding colorls completions to shell profiles"
  local completions = "$(dirname $(gem $(command -v colorls)))/tab_complete.sh"
  [ -f $HOME/.bashrc ] && echo "source $(completions)" >> $HOME/.bashrc
  [ -f $HOME/.zshrc ] && echo "source $(completions)" >> $HOME/.zshrc
}

# Install Z-shell UNIX shell (command interpreter)
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
  local xpath=$(command -v zsd)
  ln -s xpath "$(dirname xpath)/zsdoc"
}

function install_shells {
  install_zshell
  install_bash
  install_colorls
}
