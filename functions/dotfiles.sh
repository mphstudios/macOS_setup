#!bin/sh

# Install dotfiles
#
# Clones remote repository and runs `rcup` to symlink dotfiles to user directory
# @see http://thoughtbot.github.io/rcm/rcup.1.html
#
function install_dotfiles {
  install_homebrew_package rcm
  git clone https://github.com/mphstudios/dotfiles.git $HOME/Code/dotfiles
  rcup -d $HOME/Code/dotfiles
}

export -f install_dotfiles
