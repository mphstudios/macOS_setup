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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH for this session
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew analytics off
ok "Homebrew installed"
