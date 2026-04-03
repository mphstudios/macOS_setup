#!/bin/bash
set -euo pipefail

#MISE description="Install Xcode Command Line Tools"

source "${MISE_PROJECT_DIR}/lib/output.sh"

if xcode-select --print-path &>/dev/null; then
  skip "Xcode CLT"
else
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  elapsed=0
  until xcode-select --print-path &>/dev/null; do
    sleep 5
    elapsed=$((elapsed + 5))
    if [[ $elapsed -ge 1800 ]]; then
      die "Xcode CLT installation timed out. Install manually: xcode-select --install"
    fi
  done
  ok "Xcode CLT installed"
fi

# Accept the license only if not already accepted — avoids a sudo prompt on every run
xcodebuild -version &>/dev/null || sudo xcodebuild -license accept 2>/dev/null || true
