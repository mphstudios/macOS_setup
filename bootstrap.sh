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

# Load and confirm configuration
_configure() {
  local _system_computer
  _system_computer=$(scutil --get ComputerName)

  read -rp "Computer name [${COMPUTER_NAME:-$_system_computer}]: " input
  COMPUTER_NAME=${input:-${COMPUTER_NAME:-$_system_computer}}

  read -rp "Dotfiles repo [${DOTFILES_REPO:-https://github.com/mphstudios/dotfiles.git}]: " input
  DOTFILES_REPO=${input:-${DOTFILES_REPO:-https://github.com/mphstudios/dotfiles.git}}

  read -rp "Git user name [${GIT_USER_NAME:-}]: " input
  GIT_USER_NAME=${input:-${GIT_USER_NAME:-}}

  read -rp "Git email [${GIT_USER_EMAIL:-}]: " input
  GIT_USER_EMAIL=${input:-${GIT_USER_EMAIL:-}}

  read -rp "Lock screen message [${LOCK_SCREEN_MESSAGE:-We have achieved normality}]: " input
  LOCK_SCREEN_MESSAGE=${input:-${LOCK_SCREEN_MESSAGE:-We have achieved normality}}

  printf '%s\n' \
    "COMPUTER_NAME=$COMPUTER_NAME" \
    "DOTFILES_REPO=$DOTFILES_REPO" \
    "GIT_USER_EMAIL=$GIT_USER_EMAIL" \
    "GIT_USER_NAME=$GIT_USER_NAME" \
    "LOCK_SCREEN_MESSAGE=$LOCK_SCREEN_MESSAGE" \
    > .env
  printf "\n.env written.\n\n"
}

if [[ -f .env ]]; then
  source .env
  printf "Current configuration:\n"
  printf "  Computer name:     %s\n" "$COMPUTER_NAME"
  printf "  Dotfiles repo:     %s\n" "$DOTFILES_REPO"
  printf "  Git email:         %s\n" "$GIT_USER_EMAIL"
  printf "  Git user name:     %s\n" "$GIT_USER_NAME"
  printf "  Lock screen:       %s\n" "${LOCK_SCREEN_MESSAGE:-}"
  printf "\n"
  read -rp "Keep current configuration? [Y/n]: " keep
  if [[ "${keep:-Y}" =~ ^[Nn] ]]; then
    printf "\n"
    _configure
  fi
else
  printf "First run — let's configure your machine.\n\n"
  _configure
fi

# Prompt for sudo, keep-alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set lock screen message
if [[ -n "${LOCK_SCREEN_MESSAGE:-}" ]]; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$LOCK_SCREEN_MESSAGE"
  ok "Lock screen message set"
fi

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
