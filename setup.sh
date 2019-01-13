#!/usr/bin/env bash

COMPUTER=$1
SRC_DIR=$(cd "$(dirname "$0")"; pwd)
STARTTIME=$(date +%s)

fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

# script invoked without arguments
if [ ! -n $COMPUTER ]; then
  # prompt user for computer name
  read -r -p "Computer Name (Return to leave computer name unchanged):" response

  if [[ $response ]]; then
    COMPUTER=$response;
  fi
fi

# prompt for an administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set computer name (as done via System Preferences > Sharing)
if [ -n $COMPUTER ]; then
  sudo scutil --set ComputerName $COMPUTER
  sudo scutil --set HostName $COMPUTER
  sudo scutil --set LocalHostName $COMPUTER
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER
  dscacheutil -flushcache
fi

fancy_echo "Installing Xcode Command Line Tools ..."
xcode-select --install

# See https://stackoverflow.com/questions/50780183/cannot-install-brew-on-mojave-with-xcode10#50791809
# fancy_echo "Installing macOS SDK header files to /usr/include ..."
# open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg

fancy_echo "Installing Homebrew package manager ..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# ensure that node and npm install properly via Homebrew
unset -v NODE_PATH

brew update

fancy_echo "Installing Homebrew packages from Brewfile ..."
if [ ! -f "$SRC_DIR/Brewfile" ]; then
  curl -OsS https://raw.githubusercontent.com/mphstudios/macOS_setup/master/Brewfile
fi
brew bundle --file=$SRC_DIR/Brewfile --require-sha

# remove cached downloads
brew cleanup

# Install nodenv plugins that are not available as Homebrew packages
if [ -f "$HOME/.nodenv" ]; then
  fancy_echo "Installing additional nodenv plugins ..."
  PLUGINS_DIR = $(nodenv root)/plugins
  mkdir -p $PLUGINS_DIR # create the plugins dir if it does not exist
  git clone https://github.com/nodenv/nodenv-package-rehash.git "$PLUGINS_DIR/nodenv-package-rehash"
  unset $PLUGINS_DIR
  # install package hooks for all plugins
  nodenv package-hooks install --all
fi

# Install pyenv plugins that are not available as Homebrew packages
if [ -f "$HOME/.pyenv" ]; then
  fancy_echo "Installing additional pyenv plugins ..."
  PLUGINS_DIR = $(pyenv root)/plugins
  mkdir -p $PLUGINS_DIR # create the plugins dir if it does not exist

  # makes pyenv transparently aware of project-specific venv binaries created by pipenv
  # removing the need to execute these binaries with `pipenv run ${command}`
  git clone https://github.com/madumlao/pyenv-binstubs.git "$PLUGINS_DIR/pyenv-binstubs"

  # pyenv-doctor provides a command to verify pyenv installation and tools to build pythons
  git clone git://github.com/yyuu/pyenv-doctor.git "$PLUGINS_DIR/pyenv-doctor"

  # pyenv-update provides a command to update pyenv and its plugins
  git clone git://github.com/pyenv/pyenv-update.git "$PLUGINS_DIR/pyenv-update"
  unset $PLUGINS_DIR
fi

# Install rbenv plugins that are not available as Homebrew packages
if [ -f "$HOME/.rbenv" ]; then
  fancy_echo "Installing additional rbenv plugins ..."
  PLUGINS_DIR = $HOME/.rbenv/plugins/
  mkdir -p $PLUGINS_DIR # create the plugins dir if it does not exist
  git clone https://github.com/jbernsie/rbenv-clean $PLUGINS_DIR/rbenv-clean
  git clone https://github.com/alfa-jpn/rbenv-rails.git $PLUGINS_DIR/rbenv-rails
  git clone https://github.com/toy/rbenv-update-rubies.git $PLUGINS_DIR/update-rubies
  unset $PLUGINS_DIR
fi

# Install additional command shells
if [ ! fgrep -q '/usr/local/bin/bash' /etc/shells ]; then
  fancy_echo "Adding Homebrew installed Bash to /etc/shells ..."
  sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells';

  fancy_echo "Setting default shell to Homebrew installed Bash ..."
  chsh -s /usr/local/bin/bash;
fi

if [ ! fgrep -q '/usr/local/bin/fish' /etc/shells ]; then
  fancy_echo "Adding Homebrew installed Fish to /etc/shells ..."
  sudo bash -c 'echo /usr/local/bin/fish >> /etc/shells';
fi

if [ ! fgrep -q '/usr/local/bin/zsh' /etc/shells ]; then
  fancy_echo "Adding Homebrew installed Zsh to /etc/shells ..."
  sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells';
fi

# if [ -x '/bin/zsh' || '/usr/local/bin/zsh'  ]; then
#   fancy_echo "Installing 'Oh My Zsh' configuration framework ..."
#   curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
# fi

# if [ ! -e "$HOME/.vim/autoload/plug.vim" ]; then
#   fancy_echo "Installing Vim plugin manager vim-plug ..."
#   curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
#     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# fi

fancy_echo "Installing Homebrew and NPM package update notifiers ..."
if ! command terminal-notifier > /dev/null; then
  fancy_echo "terminal-notifier is required, installing now ..."
  brew install terminal-notifier
fi

cp -fX $SRC_DIR/bin/*-notifier /usr/local/bin/

# Set permissions on notifier scripts
chmod 755 /usr/local/bin/brew-updates-notifier
chmod 755 /usr/local/bin/npm-outdated-notifier

if [ ! -d ~/Library/LaunchAgents ]; then
  mkdir ~/Library/LaunchAgents
fi

cp -fX $SRC_DIR/LaunchAgents/*.plist ~/Library/LaunchAgents/

# User LaunchAgents must be readable by the user
# and must NOT be writable by the group or other
chmod 644 ~/Library/LaunchAgents/homebrew-updates-notifier.plist
chmod 644 ~/Library/LaunchAgents/npm-outdated-notifier.plist

fancy_echo "Installing applications from Homebrew Caskfile ..."
if [ ! -f "$SRC_DIR/Caskfile" ]; then
  curl -OsS https://raw.githubusercontent.com/mphstudios/macOS_setup/master/Caskfile
fi
brew bundle --file=$SRC_DIR/Caskfile --require-sha

# remove cached downloads
brew cask cleanup

fancy_echo "Installing fonts from Homebrew CaskFonts ..."
if [ ! -f "$SRC_DIR/CaskFonts" ]; then
  curl -OsS https://raw.githubusercontent.com/mphstudios/macOS_setup/master/CaskFonts
fi
brew bundle --file=$SRC_DIR/CaskFonts --require-sha

# remove cached downloads
brew cask cleanup

fancy_echo "Linking ssh config to Dropbox ..."
if [ -f "~/.ssh/config" ]; then
  mv ~/.ssh/config ~/.ssh/config_old
fi
ln -fs ~/Dropbox/.ssh-config ~/.ssh/config

fancy_echo "Starting ssh-agent in the background ..."
eval "$(ssh-agent -s)"

fancy_echo "Linking Sublime Text settings to Dropbox ..."
SUBLIME_SETTINGS_DIR="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
if [[ ! -L "$SUBLIME_SETTINGS_DIR" ]]; then
  rm -rf SUBLIME_SETTINGS_DIR
fi
ln -sfn ~/Dropbox/Apps/Sublime\ Text/User SUBLIME_SETTINGS_DIR

fancy_echo "Creating symlink for Sublime Text command line tool ..."
ln -fs /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

# fancy_echo "Writing defaults for system, services, and applications ..."
# if [ ! -f "$SRC_DIR/defaults_write.sh" ]; then
#   curl -OsS https://raw.githubusercontent.com/mphstudios/macOS_setup/master/defaults_write.sh
# fi
# ssh $SRC_DIR/defaults_write.sh

ENDTIME=$(date +%s)

fancy_echo "Setup of $HOSTNAME completed.\n
  elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
read -r -p "Would you like to restart the system now? [y/N]" response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
  shutdown -r now "Restarting $HOSTNAME" ;
else
  fancy_echo "goodbye"; exit;
fi
