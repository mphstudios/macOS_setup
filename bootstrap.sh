#!/bin/bash
set -euo pipefail

# Thin bootstrap for macOS setup
# Installs prerequisites that mise needs, then hands off to mise tasks.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/output.sh"

# Abort if not macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script can only be run on macOS."
fi

# Create .env if it doesn't exist (interactive prompts)
if [[ ! -f .env ]]; then
  printf "First run — let's configure your machine.\n\n"
  computer=$(scutil --get ComputerName)
  read -rp "Computer name [$computer]: " input
  computer=${input:-$computer}
  read -rp "Git user name: " git_name
  read -rp "Git email: " git_email
  read -rp "Dotfiles repo [https://github.com/mphstudios/dotfiles.git]: " dotfiles
  dotfiles=${dotfiles:-https://github.com/mphstudios/dotfiles.git}
  printf '%s\n' \
    "COMPUTER_NAME=$computer" \
    "DOTFILES_REPO=$dotfiles" \
    "GIT_USER_EMAIL=$git_email" \
    "GIT_USER_NAME=$git_name" \
    > .env
  printf "\n.env written.\n\n"
fi

# Prompt for sudo, keep-alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Rosetta 2 on Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto > /dev/null 2>&1; then
    info "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
    ok "Rosetta 2"
  else
    skip "Rosetta 2"
  fi
fi

# Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Poll until installed (the UI installer runs asynchronously)
  # Timeout after 30 minutes in case the dialog is dismissed
  elapsed=0
  until xcode-select -p &>/dev/null; do
    sleep 5
    elapsed=$((elapsed + 5))
    if [[ $elapsed -ge 1800 ]]; then
      die "Xcode CLT installation timed out. Install manually: xcode-select --install"
    fi
  done
  ok "Xcode CLT installed"
else
  skip "Xcode CLT"
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for this session
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  skip "Homebrew"
fi

# Install mise
if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  brew install mise
  ok "mise installed"
else
  skip "mise"
fi

# Hand off to mise
printf "\nBootstrap complete. Running mise setup...\n\n"
mise run setup
