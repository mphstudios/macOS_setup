#!/bin/bash
set -euo pipefail

#MISE description="Install Homebrew package manager"
#MISE depends=["install:xcode"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

if command -v brew &>/dev/null; then
  skip "Homebrew"
  exit 0
fi

info "Installing Homebrew..."
spin "Installing Homebrew..." \
  bash -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

# Persist Homebrew in PATH via /etc/paths.d (read by path_helper for all shells)
# Only needed on Apple Silicon (/usr/local/bin is already in the default PATH on Intel)
if [[ "$(uname -m)" == "arm64" ]] && [[ ! -f /etc/paths.d/homebrew ]]; then
  printf '/opt/homebrew/bin\n/opt/homebrew/sbin\n' | sudo tee /etc/paths.d/homebrew > /dev/null
  eval "$(/usr/libexec/path_helper)"
fi

brew analytics off
ok "Homebrew installed"
