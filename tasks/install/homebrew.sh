#!/bin/bash
set -euo pipefail

#MISE description="Install Homebrew package manager"

source "${MISE_PROJECT_DIR}/lib/output.sh"

xcode-select -p &>/dev/null || die "Xcode CLT is required — run 'mise run install:xcode'"

if command -v brew &>/dev/null; then
  verified "Homebrew"
  exit 0
fi

spin "Installing Homebrew..." \
  bash -c 'curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash'

# Persist Homebrew in PATH via /etc/paths.d (read by path_helper for all shells)
# Only needed on Apple Silicon (/usr/local/bin is already in the default PATH on Intel)
if [[ "$(uname -m)" == "arm64" ]] && [[ ! -f /etc/paths.d/homebrew ]]; then
  printf '/opt/homebrew/bin\n/opt/homebrew/sbin\n' | sudo tee /etc/paths.d/homebrew > /dev/null
  eval "$(/usr/libexec/path_helper)"
fi

brew analytics off
ok "Homebrew installed"
