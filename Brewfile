##
# Homebrew Bundle
# https://github.com/Homebrew/homebrew-bundle
#
# Running `brew leaves` will show installed formulae that are not dependencies
# of another installed formula.
#
# To generate a base Brewfile run the following commands:
#
#   `brew tap | sed "s/^.*/tap '&'/" > Brewfile`
#   `brew leaves | sed "s/^.*/brew '&'/" >> Brewfile`
#
# To generate a Brewfile listing all installed packages, casks, and dependecies,
# run the command `brew bundle dump -f > Brewfile`
#
# This Brewfile can also be used as a whitelist and uninstall all Homebrew
# formulae not listed in Brewfile by using the command `brew bundle cleanup`
#
##

## Additional Homebrew repositories
tap 'homebrew/bundle'
tap 'homebrew/core'
tap 'homebrew/services'
tap 'thoughtbot/formulae'

## Update GNU Bourne Again SHell
brew 'bash'
brew 'bash-completion@2'

# Bash completion for Ruby commands
brew 'bundler-completion'
brew 'gem-completion'
brew 'rails-completion'
brew 'rake-completion'
brew 'ruby-completion'

brew 'openssl && brew link --force openssl'

# GNU utils
brew 'coreutils'#, args: [ 'with-default-names' ]
brew 'findutils'#, args: [ 'with-default-names' ]

## newer versions of macOS installed tools
brew 'curl', args: [ 'with-openssl', 'with-ssh' ]
brew 'grep', args: [ 'with-default-names' ]
brew 'rsync'

## Update Git, add support for versioning large files and using GitHub commands
brew 'git', args: [ 'with-curl', 'with-openssl' ]
brew 'git-lfs'
brew 'hub'

# Python
brew 'python'
brew 'python3'
brew 'pipenv' # Python packaging tool

# Ruby
# brew 'rbenv'
# brew 'rbenv-bundle-exec'
# brew 'rbenv-gemset'
# brew 'rbenv-use'
# brew 'rbenv-vars'
# brew 'ruby-build'

## more useful binaries
brew 'ack'
brew 'dnsmasq', link: false
brew 'dockutil'
brew 'duti'
brew 'exa'
brew 'fzy'
brew 'gpg2', args: [ 'with-readline' ]
brew 'heroku'
brew 'imagemagick', args: [ 'with-webp' ]
brew 'libyaml'
brew 'macvim', args: [ 'with-python3' ]
brew 'most'
brew 'ngrok'
brew 'node'
brew 'passenger'
brew 'rcm'  # thoughtbot management suite for dotfiles
brew 'rename'
brew 'ssh-copy-id'
brew 'sshuttle'
brew 'terminal-notifier'
brew 'the_silver_searcher'
brew 'thefuck'
brew 'tmux'
brew 'trash'
brew 'tree'
brew 'vcprompt'
brew 'watchman'
brew 'webkit2png'
brew 'wget'
brew 'yarn'
brew 'zsh'

## Databases
brew 'jena', restart_service: :changed
brew 'mongodb', args: [ 'with-openssl' ], restart_service: :changed
brew 'mysql', restart_service: :changed
brew 'orientdb', restart_service: :changed
brew 'postgres', args: [ 'with-python', 'without-perl', 'without-tcl' ], restart_service: :changed
brew 'postgis'
brew 'redis', restart_service: :changed
brew 'sqlite', restart_service: :changed
