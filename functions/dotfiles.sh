#!bin/sh

# Install dotfiles
#
# Clones remote repository and runs `rcup` to symlink dotfiles to user directory
# @see http://thoughtbot.github.io/rcm/rcup.1.html
#
# @todo refactor to read or write the the rcrc DOTFILES_DIRS property
#
function install_dotfiles {
  local dotfiles=$HOME/Code/dotfiles

  install_homebrew_package 'rcm'
  
  if [ ! -d "$dotfiles" ]
  then
    git clone https://github.com/mphstudios/dotfiles.git $dotfiles
    cp $dotfiles/rcrc $HOME/.rcrc
    rcup -d $dotfiles
  else
    message "$CHECK_MARK dotfiles installed"
  fi
}
