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
tap 'jawshooah/pyenv'
tap 'nodenv/nodenv'
tap 'osgeo/osgeo4mac'
tap 'thoughtbot/formulae'

## Update GNU Bourne Again SHell
brew 'bash'
brew 'bash-completion@2'

## Bash completion for Ruby commands
brew 'bundler-completion'
brew 'gem-completion'
brew 'rails-completion'
brew 'rake-completion'
brew 'ruby-completion'

## GNU utils
brew 'coreutils' # GNU File, Shell, and Text utilities
brew 'findutils' # GNU find, xargs, and locate
brew 'parallel' # Shell command parallelization utility

## newer versions of macOS installed tools
brew 'curl', args: ['with-openssl', 'with-ssh']
brew 'grep', args: ['with-default-names']
brew 'rsync' # fast incremental file transfer utility
#brew 'vim', args: ['with-override-system-vi']

## Update Git, add support for versioning large files and using GitHub commands
brew 'git', args: ['with-curl', 'with-openssl']
brew 'git-lfs' # git large file storage
brew 'gitsh' # thoughtbot's interactive shell for git
brew 'hub' # command-line interface for GitHub

## Node version manager
brew 'nodenv' # Node version management
brew 'nodenv-default-packages'
brew 'nodenv-npm-migrate'
brew 'nodenv-package-json-engine'

## Python
brew 'python'
brew 'python3'
brew 'pyenv' # Python version management
brew 'pyenv-default-packages' # automatically install packages after install a new version of Python or create a new virtualenv
brew 'pyenv-virtualenv' # manage virtualenvs with pyenv
brew 'pyenv-which-ext' # automatically lookup system command if the specified command has not been installed in pyenv
brew 'pipenv' # dependency management tool

## Ruby version manager
brew 'rbenv'
brew 'rbenv-binstubs' # makes rbenv transparently aware of project-specific binstubs created by bundler. This means you do not have to type bundle exec ${command} ever again!
brew 'rbenv-bundle-exec' # makes rbenv run ruby executables using `bundle exec`
brew 'rbenv-bundler-ruby-version' # use Ruby version from Gemfile
brew 'rbenv-default-gems' # automatically install specific gems after installing a new Ruby
brew 'rbenv-use' # RVM-style `use` command to switch between Ruby versions

## more useful binaries
brew 'ack' # Search tool like grep, but optimized for programmers
brew 'csvkit' # Suite of command-line tools for working with csv data
brew 'direnv' # Load/unload environment variables based on $PWD
brew 'dnsmasq', link: false # Lightweight DNS forwarder and DHCP server
brew 'dockutil' # Tool for managing dock items
brew 'duti' # Select default apps for documents and URL schemes on macOS
brew 'exa'  # Modern replacement for shell `ls` command
brew 'fd' # a simple, fast, and user-friendly alternative to `find`
brew 'fish' # User-friendly command-line shell for UNIX-like operating systems
brew 'fzf'  # a general-purpose command-line fuzzy finder
brew 'fzy' # Fast, simple fuzzy text selector with an advanced scoring algorithm
brew 'gpg2', args: ['with-readline'] # GNU Pretty Good Privacy (PGP) package
#brew 'graphviz', args: ['with-app', 'with-bindings', 'with-librsvg', 'with-freetype']
brew 'heroku/brew/heroku' # Command-line client for the cloud PaaS
brew 'highlight' # convert source code to formatted text with syntax highlighting
brew 'jupyter' # Interactive environments for writing and running code
brew 'jq' # Lightweight and flexible command-line JSON processor
brew 'jsonlint' # JSON parser and validator with a CLI
brew 'librsvg' # Library to render SVG files using Cairo
brew 'libyaml' # YAML Parser
brew 'macvim', args: ['with-override-system-vim'] # GUI for vim made for macOS
brew 'mosh' # A mobile shell replacement for interactive SSH terminals
brew 'most' # Powerful paging program
brew 'neofetch' # command-line system information tool
brew 'neovim' # drop-in replacement for Vim with built-in terminal emulation
brew 'node' # Platform built on V8 to build network applications
brew 'passenger' # Application server for Ruby, Python, and Node.js
brew 'pick' # thoughtbot's fuzzy search tool to select an entry from a list
brew 'puma/puma/puma-dev' # development server for rack applications
brew 'ranger' # a console file manager with VI key bindings
brew 'rcm'  # thoughtbot's management suite for dotfiles
brew 'rename' # Perl-powered file rename script with many helpful built-ins
brew 'ripgrep' # tool to recursively search directories for a regex pattern
brew 'smartmontools' # SMART hard drive monitoring
brew 'ssh-copy-id' # Add a public key to a remote machine's authorized_keys file
brew 'sshuttle' # Proxy server that works as a poor man's VPN
brew 'terminal-notifier' # Send macOS User Notifications from the command-line
brew 'the_silver_searcher' # Code-search similar to ack! with a focus on speed.
brew 'thefuck' # Programatically correct mistyped console commands
brew 'tmate' # Tmux fork for instant terminal sharing
brew 'tmux' # Terminal multiplexer
brew 'tmuxinator-completion' # Shell completion for Tmuxinator
brew 'trash' # CLI tool that moves files or folder to the trash
brew 'tree' # Display directories as trees (with optional color/HTML output)
brew 'vcprompt' # Provide version control info in shell prompts
brew 'w3m' # text-based web browser and pager like `more' or `less'
brew 'watchman' # Watch files and take action when they change
brew 'webkit2png' # Create screenshots of webpages from the terminal
brew 'wemux' # Enhances tmux to provide multiuser terminal multiplexing
brew 'wget' # non-interactive tool to retrieve files using HTTP/HTTPS/FTP/FTPS
brew 'yarn' # JavaScript dependency package manager

# image processing tools
brew 'exiftool' # PERL library for reading and writing EXIF metadata
brew 'graphicsmagick', args: ['with-webp']
brew 'imagemagick', args: ['without-modules', 'with-zero-configuration']
brew 'jp2a' # utility that converts JPG images to ASCII
brew 'vips' # Image processing library

# code linting tools
brew 'shellcheck' # shell script static analysis tool

# Z Shell
brew 'zsh'
brew 'zsh=autosuggestions'
brew 'zsh-completions'
brew 'zplug'

## Databases
brew 'jena' # triple store for semantic web and linked data applications
brew 'mongodb', args: ['with-openssl'], restart_service: :changed, start_service: false
brew 'mysql', restart_service: :changed, start_service: false
brew 'postgres', args: ['with-python', 'without-perl', 'without-tcl'], restart_service: :changed, start_service: false
brew 'postgis' # spatial and geographic objects for PostgreSQL
brew 'pgcli' # Postgres CLI with auto-completion and syntax highlighting
brew 'redis', restart_service: :changed, start_service: false
brew 'sqlite'
