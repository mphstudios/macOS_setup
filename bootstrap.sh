#!/bin/bash
set -euo pipefail

# Thin bootstrap for macOS setup
# Installs prerequisites that mise needs, then hands off to mise tasks.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export MISE_PROJECT_DIR="$SCRIPT_DIR"
source "$SCRIPT_DIR/lib/output.sh"

# Abort if not macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This script can only be run on macOS."
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
bash "$SCRIPT_DIR/tasks/install/xcode.sh"

# Install Homebrew
bash "$SCRIPT_DIR/tasks/install/homebrew.sh"
# Reload PATH from /etc/paths.d after install to pick up Homebrew bin directory
eval "$(/usr/libexec/path_helper)"

# Install mise
if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  brew install mise
  ok "mise installed"
else
  skip "mise"
fi

# Trust the project and install mise tools (usage, gum) so tasks are available
mise trust --yes "$SCRIPT_DIR"
mise install

# Configure environment (writes .env via gum input)
printf "\nBootstrap complete.\n\n"
bash "$SCRIPT_DIR/tasks/configure/env.sh"

# Apply lock screen message from .env now that it has been written
source "$SCRIPT_DIR/.env" 2>/dev/null || true
if [[ -n "${LOCK_SCREEN_MESSAGE:-}" ]]; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$LOCK_SCREEN_MESSAGE"
  ok "Lock screen message set"
fi

mise run setup
