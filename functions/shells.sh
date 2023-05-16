#!/bin/sh

function add_shell {
  local shell="$(command -v $1)"
  local default=${2:-false}

  if [[ -z $shell ]]
  then
    echo "shell is a required argument"
    return 0
  fi

  if ! grep "$shell" /etc/shells >& /dev/null 2>&1 
  then
    message "Adding $shell to /etc/shells"
    sudo sh -c "echo $shell >> /etc/shells"
  fi

  if [ "$default" = true ]
  then
    sudo chsh -s $shell $USER
  fi
}

# Install Bourne-Again SHell, UNIX command interpreter
function install_bash {
  install_homebrew_package 'bash'
  install_homebrew_package 'bash-completion@2'
  add_shell 'bash'
}

# Install Z-shell UNIX shell (command interpreter)
function install_zshell {
  install_homebrew_package 'zsh'
  install_homebrew_package 'zsh-autosuggestions'
  install_homebrew_package 'zsh-completions'
  install_homebrew_package 'zplug'
  add_shell 'zsh' true
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
  install_bash
  install_zshell
}
