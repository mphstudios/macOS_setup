#!/usr/bin/env bash

COMPUTER=$1
SRC_DIR=$(cd "$(dirname "$0")/.."; pwd)
STARTTIME=$(date +%s)

fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

fancy_echo "Installing Xcode Command Line Tools ..."
xcode-select --install

fancy_echo "Installing Homebrew package manager ..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# ensure that node + npm install properly via Homebrew
unset -v NODE_PATH

brew update

fancy_echo "Installing Homebrew packages from Brewfile ..."
brew bundle ./Brewfile

# remove cached downloads
brew cleanup

fancy_echo "Setting default shell to Homebrew installed Bash ..."
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

fancy_echo "Installing Homebrew and NPM package update notifiers ..."
ln -s $SRC_DIR/bin/brew-updates-notifier.sh /usr/local/bin/brew-updates-notifier.sh
ln -s $SRC_DIR/bin/npm-outdated-notifier.sh /usr/local/bin/npm-outdated-notifier.sh
cp $SRC_DIR/LaunchAgents/*.plist ~/Library/LaunchAgents/

fancy_echo "Installing RVM and Ruby ..."
curl -sSL https://get.rvm.io | bash -s stable --ruby

fancy_echo "Installing gems to default Ruby ..."
gem install bundler
bundle install --gemfile=$SRC_DIR/Gemfile

fancy_echo "Installing applications from Homebrew Caskfile ..."
brew bundle ./Caskfile

# remove cached downloads
brew cask cleanup

fancy_echo "Linking ssh config to Dropbox ..."
ln -s ~/Dropbox/.ssh-config ~/.ssh/config

fancy_echo "Linking Sublime Text settings to Dropbox ..."
ln -s ~/Dropbox/Sublime\ Text/User ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

fancy_echo "Creating symlink for Sublime Text command line tool ..."
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

fancy_echo "Writing defaults for system, services, and applications ..."
./defaults_write.sh

# ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set computer name (as done via System Preferences > Sharing)
if [ -n $COMPUTER ]; then
  sudo scutil --set ComputerName $COMPUTER
  sudo scutil --set HostName $COMPUTER
  sudo scutil --set LocalHostName $COMPUTER
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER
fi

ENDTIME=$(date +%s)

fancy_echo "Setup of $HOSTNAME completed.\n
  elapsed time $((ENDTIME - STARTTIME))"

# Ask for confirmation before restarting the computer
read -r -p "Would you like to restart the system now [y/N]" response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
  shutdown -r now "Restarting $HOSTNAME" ;
else
  echo "goodbye"; exit;
fi
